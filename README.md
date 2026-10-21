# Positive User iOS SDK

iOS SDK for [Positive User / user.com](https://user.com). It lets your app:

- track users and events
- send screen views
- handle push notifications
- show in-app messages

> Naming: the pod is `UserSDK`, the module you import is `UserComSDK`, the main class is `UserSDK`.

---

## New in 1.3.0

- Links from User.com emails: `handleEmailLink` counts the click and gives your app the target of the link.
- One method per contact update: `updateContact` with a `Contact`. The SDK no longer keeps a copy of contact data.
- Received notifications and taps are passed separately: `handleNotification(_:)` never counts a click, `handleNotificationClick(_:)` does.
- Every failure is a `UserSDKError`, and `UserSDK.errorHandler` receives all of them in one place, for example to log them to Crashlytics.
- After logout the anonymous contact keeps the push token, so the device still receives pushes.
- Data that cannot be sent (a `Date` in attributes, an empty event name) returns an error instead of crashing the app.
- Completions always run on the main thread.
- An app woken in the background on a locked phone no longer creates a duplicate contact.
- New names: `sendEvent(name:attributes:)`, `trackScreen(name:)`, `sendProductEvent(_:eventType:attributes:)`, `userKey`, `inAppMessageClickHandler`. The old names still work and are deprecated until 2.0.

Behavior changes to check: see [MIGRATION.md](MIGRATION.md).

## New in 1.2.0

- In-app messages are shown in their own window, so your navigation (splash screens, `.fullScreen` presentations, a replaced `rootViewController`) no longer blocks them, and you can present your own screens while one is visible.
- An in-app message received while the app is in the background is shown the next time the app becomes active, if it arrived less than 6 hours earlier. Only the newest one is kept.
- `displayed` is reported only once the message is actually on screen.
- Notification handling moves to the main thread by itself, so calling `handleNotification` from a `Task`, an actor or a background queue is safe.
- `setUserData` and `setCustomUserData` accept an optional `fcmToken`.
- The device iOS version and the SDK version are now stored correctly on the contact.

Behavior changes to check: product event `params` are sent as separate product attributes (before 1.2.0 they were nested under `custom_data` and stored as a single JSON attribute), and `logout` now records a `logout` event for the user who is leaving. See [MIGRATION.md](MIGRATION.md).

## New in 1.1.1

- Fixed in-app click tracking. The click callback now sends the URL where the backend expects it, so in-app clicks are counted again.

## New in 1.1.0

- More reliable event delivery. A failed request retries with a growing backoff and never blocks other events.
- HTTP errors now reach your completion handlers. Before, some rejected requests looked like a success.
- In-app button taps are always tracked, including custom scheme deeplinks handled by your click delegate.

Behavior change to check: `sendEvent`, `trackScreen` and similar methods now call `completion(false, error)` when the server rejects the request (for example 400 or 401). Before 1.1.0 they reported success. If your code treated `true` as proof of delivery, review that logic.

Migrating from 0.7.x? See [MIGRATION.md](MIGRATION.md).

---

## BYOT (Bring Your Own Token)

The SDK has zero external dependencies. No Firebase, no Gifu.

- You own Firebase. The SDK does not initialize Firebase and does not claim the messaging delegate.
- You provide the FCM token to the SDK (see below).
- The SDK asks for notification permission only if you call `registerForRemoteNotifications(...)`.
- GIFs in in-app messages are decoded in the SDK via ImageIO.

---

## Installation

### Swift Package Manager

```
https://github.com/UserEngage/iOS-SDK.git
Exact Version: 1.3.0
```

The package is self-contained. No extra dependencies required.

### CocoaPods

```ruby
pod 'UserSDK', :git => 'https://github.com/UserEngage/iOS-SDK.git', :tag => '1.3.0'
```

```bash
pod install
```

### Import

```swift
import UserComSDK
```

---

## Initialization

```swift
let sdk = UserSDK(
    application: application,
    apiKey: "YOUR_SDK_KEY",           // Mobile SDK Key (Settings, App Settings, Advanced, Mobile keys)
    baseURL: "your-domain.user.com",  // your app domain
    shouldTrackActivities: false,     // deprecated, no effect
    fcmToken: fcmToken                // optional, can also be set later via setFcmToken(_:)
)

sdk.ping()                            // creates or updates the contact
```

Events and screens need a contact, so call `ping()` successfully before you send them. Before that they end with `UserSDKError.notIdentified`.

---

## FCM token (BYOT)

You provide the FCM token. Pass it at init, via `setFcmToken(_:)`, or with a ping:

```swift
UserSDK.default?.setFcmToken(token)          // registers the token on the current contact
UserSDK.default?.ping(fcmToken: token)       // ping carrying the token in the device payload
```

Call `setFcmToken(_:)` again whenever Firebase rotates the token.

---

## Push notifications

### If you do not have your own push stack

Let the SDK request permission and register for APNs:

```swift
UserSDK.default?.registerForRemoteNotifications(
    options: [.alert, .badge, .sound],
    notificationDelegate: self            // optional RemoteNotificationDelegate
)
```

### If you already use Firebase or manage push yourself

Do not call `registerForRemoteNotifications(...)`. Keep your own notification-center delegate. Forward incoming notifications to the SDK and provide the token:

```swift
// own your delegate
UNUserNotificationCenter.current().delegate = self

// token refresh (Firebase MessagingDelegate)
func messaging(_ m: Messaging, didReceiveRegistrationToken token: String?) {
    if let token { UserSDK.default?.setFcmToken(token) }
}

// a tap on a notification: the SDK counts the click
func userNotificationCenter(_ c: UNUserNotificationCenter, didReceive r: UNNotificationResponse,
                            withCompletionHandler done: @escaping () -> Void) {
    UserSDK.default?.handleNotificationClick(r.notification.request.content.userInfo)
    done()
}

// a received notification (silent pushes carry in-app messages): never a click
func application(_ a: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                 fetchCompletionHandler done: @escaping (UIBackgroundFetchResult) -> Void) {
    UserSDK.default?.handleNotification(userInfo)
    done(.noData)
}
```

`handleNotification(_:)` returns `true` for a User.com notification and `false` for any other, so you can handle your own pushes as usual. You can also pass notifications from `willPresent` to it: receiving a notification is never counted as a click. `isUserComNotification(_:)` checks a payload without side effects.

`handleNotificationClick(_:)` reports the click and passes the payload to your `RemoteNotificationDelegate` (link, screen name). A push without a link has `link` set to `"None"`: treat it like no link.

If the SDK is your notification-center delegate (you called `registerForRemoteNotifications(...)`), it handles taps itself and shows notifications received in the foreground.

---

## In-app message clicks

Handle in-app button taps yourself, for example to open a deeplink:

```swift
UserSDK.default?.inAppMessageClickHandler = { url in
    // return true if you handled the URL (deeplinks, custom schemes)
    // return false to let the SDK open it in the browser
    router.open(url)
    return true
}
```

The handler receives every URL, including custom scheme deeplinks, on the main thread. The SDK opens the URL itself only if you return `false`. The click is reported either way.

---

## Events

```swift
UserSDK.default?.sendEvent(name: "purchase", attributes: ["amount": 99])
UserSDK.default?.trackScreen(name: "Home")
UserSDK.default?.sendProductEvent("SKU-1", eventType: .addToCart, attributes: ["name": "Mug", "price": 29])
```

- Keep one spelling and case per event name: `Purchase` and `purchase` collide.
- Attribute values must be JSON values: `String`, numbers, `Bool`, arrays, dictionaries. Each new key creates an attribute in the panel, its type set by the first value.
- An event name must not be empty, longer than 255 characters or contain HTML. A screen name is at most 128 characters.

## Contact data

```swift
let contact = Contact(userId: "42", email: "jane@example.com", firstName: "Jane",
                      attributes: ["plan": "pro"])
UserSDK.default?.updateContact(contact, fcmToken: fcmToken) { success, error in }
```

- What you pass is added to the contact. A field you leave `nil` keeps its value.
- The SDK keeps no copy: later pings do not repeat it.
- A `userId` different from the current contact's switches to the contact with that id. Call `updateContact` at login, with the push token, so both reach the backend in one request.
- Custom attributes must exist in the panel. `attributes` also takes standard ones such as `gender` or `score`.
- `UserSDK.default?.userKey` is the key of the contact the SDK sends data for.

## Links from emails

Links in User.com emails point to a tracking address on your User.com domain. When such a link opens your app (Universal Link), pass the URL to the SDK. It counts the click and gives you the target the email links to:

```swift
.onOpenURL { url in
    Task {
        if let target = await UserSDK.default?.handleEmailLink(url) {
            router.open(target)          // a screen of your app, or the browser with the target
        } else {
            router.open(url)             // not a link from a User.com email
        }
    }
}
```

The same works with a completion: `handleEmailLink(url) { target in }`.

- Pass every incoming URL. For other links the SDK returns `nil` without a request.
- Never open the tracking link itself in the browser: that counts a second click.
- Without a connection the target still comes from the link, only the click is lost.
- The target is returned unchanged. Ignore query parameters you do not use when you route it.

## Errors

Every failure reaches your completion as a `UserSDKError`. `UserSDK.errorHandler` receives all of them on the main thread, also from calls without a completion:

```swift
UserSDK.errorHandler = { error in
    Crashlytics.crashlytics().record(error: error)
}
```

| Error | Meaning |
|---|---|
| `notIdentified` | no contact yet, call `ping()` first |
| `invalidName` | event name, screen name or product id not accepted |
| `invalidData` | an attribute value JSON cannot hold, or an empty key |
| `rejected(statusCode:)` | the server refused the request |
| `network` | no connection after all retries |
| `notCollectingData` | the app does not collect data (check the panel) |
| `invalidConfiguration` | wrong base URL |
| `loggedOut` | dropped because the user logged out first |

A request waiting offline is not an error: its result comes when it is sent or finally dropped. Completions always run on the main thread.

## Logout

Pass the FCM token to unbind it from the logged-out user:

```swift
UserSDK.default?.logout(fcmToken: currentFcmToken) { success, error in }
```

The anonymous contact created after logout gets the same push token, so the device keeps receiving pushes. Turning pushes off after logout is up to your app.

---

## In-app messages, custom fonts

```swift
UserSDK.default?.fontResolver = FontResolver()   // a type conforming to FontResolving
```

```swift
public protocol FontResolving {
    func resolveFontFor(name: String, size: CGFloat) -> UIFont?
}
```

Set `fontResolver` after initializing the SDK.

---

## License

MIT
