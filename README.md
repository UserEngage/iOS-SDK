# Positive User iOS SDK

iOS SDK for [Positive User / user.com](https://user.com). It lets your app:

- track users and events
- send screen views
- handle push notifications
- show in-app messages

> Naming: the pod is `UserSDK`, the module you import is `UserComSDK`, the main class is `UserSDK`.

---

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
Exact Version: 1.2.0
```

The package is self-contained. No extra dependencies required.

### CocoaPods

```ruby
pod 'UserSDK', :git => 'https://github.com/UserEngage/iOS-SDK.git', :tag => '1.2.0'
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

`trackScreen` and events need a contact, so call `ping()` successfully before you send them.

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

// forward taps and silent pushes (in-app messages).
// Do not forward willPresent: every handleNotification call counts as a click.
func userNotificationCenter(_ c: UNUserNotificationCenter, didReceive r: UNNotificationResponse,
                            withCompletionHandler done: @escaping () -> Void) {
    UserSDK.default?.handleNotification(userInfo: r.notification.request.content.userInfo)
    done()
}

func application(_ a: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                 fetchCompletionHandler done: @escaping (UIBackgroundFetchResult) -> Void) {
    UserSDK.default?.handleNotification(userInfo: userInfo)
    done(.noData)
}
```

The SDK acts only on User.com notifications. Everything else is passed back to your `RemoteNotificationDelegate`. Your own pushes keep working.

---

## In-app message clicks

Handle in-app button taps yourself, for example to open a deeplink:

```swift
UserSDK.default?.inAppNotificationClickDelegate = self

func inAppNotificationDidClick(url: URL) -> Bool {
    // return true if you handled the URL (deeplinks, custom schemes)
    // return false to let the SDK open it in the browser
    router.open(url)
    return true
}
```

The delegate receives every URL, including custom scheme deeplinks. The SDK opens the URL itself only if you return `false`.

---

## Events and user data

```swift
UserSDK.default?.sendEvent(with: "purchase", params: ["amount": 99])
UserSDK.default?.trackScreen(with: "Home")
UserSDK.default?.setUserData([.email: "jane@example.com", .firstName: "Jane"])
UserSDK.default?.setCustomUserData(["plan": "pro"])
```

## Logout

Pass the FCM token to unbind it from the logged-out user:

```swift
UserSDK.default?.logout(fcmToken: currentFcmToken) { success, error in }
```

After logout, call `setFcmToken(_:)` again if the new anonymous user should receive pushes.

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
