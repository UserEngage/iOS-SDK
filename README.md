# Positive User iOS SDK

iOS SDK for [Positive User](https://user.com). Track users, send events, handle
push notifications and display in-app messages.

> **Naming:** the pod is `UserSDK`, the module you import is `UserComSDK`, and the main class is `UserSDK`.

---

## 1.0.0 Own FCM Token

Starting with **1.0.0** SDK has **zero external dependencies**.

- **You own Firebase.** Provide FCM token to the SDK (see below).
- **No more auto-prompt.** SDK only asks for notification permission if *you* call
  `registerForRemoteNotifications(...)`. If you manage push yourself, it never prompts.
- **GIFs** in in-app messages are decoded in-SDK via ImageIO.

Migrating from 0.7.x? See **[MIGRATION.md](MIGRATION.md)**.

---

## Installation

### Swift Package Manager

```
https://github.com/UserEngage/iOS-SDK.git
Exact Version: 1.0.0
```

No extra dependencies required, the package is self-contained.

### CocoaPods

```ruby
pod 'UserSDK', :git => 'https://github.com/UserEngage/iOS-SDK.git', :tag => '1.0.0'
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
    apiKey: "YOUR_SDK_KEY",           // Mobile SDK Key (Settings → App Settings → Advanced → Mobile keys)
    baseURL: "your-domain.user.com",  // your app domain
    shouldTrackActivities: false,
    fcmToken: fcmToken                // optional; can also be set later via setFcmToken(_:)
)

sdk.ping()                            // creates/updates the contact
```

---

## FCM token

You provide the FCM token. Pass it at init, via `setFcmToken(_:)`, or with a ping:

```swift
UserSDK.default?.setFcmToken(token)          // registers the token on the current contact
UserSDK.default?.ping(fcmToken: token)       // ping carrying the token in the device payload
```

Call `setFcmToken(_:)` again whenever Firebase rotates the token.

---

## Push notifications

### If you don't have your own push stack

Let the SDK request permission and register for APNs:

```swift
UserSDK.default?.registerForRemoteNotifications(
    options: [.alert, .badge, .sound],
    notificationDelegate: self            // optional RemoteNotificationDelegate
)
```

### If you already use Firebase / manage push yourself

**Do not** call `registerForRemoteNotifications(...)` — keep the notification-center delegate.
Just forward incoming notifications to the SDK and provide the token:

```swift
// own your delegate
UNUserNotificationCenter.current().delegate = self

// token refresh (Firebase MessagingDelegate)
func messaging(_ m: Messaging, didReceiveRegistrationToken token: String?) {
    if let token { UserSDK.default?.setFcmToken(token) }
}

// forward taps / foreground / silent pushes
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

The SDK only acts on notifications it recognizes (User.com payloads); everything else is passed
back untouched to your `RemoteNotificationDelegate`. Your own pushes keep working in parallel.

---

## Events & user data

```swift
UserSDK.default?.sendEvent(with: "purchase", params: ["amount": 99])
UserSDK.default?.trackScreen(with: "Home")
UserSDK.default?.setUserData([.email: "jane@example.com", .firstName: "Jane"])
UserSDK.default?.setCustomUserData(["plan": "pro"])
```

## Logout

You explicitly pass the FCM token to unbind from the logged-out user:

```swift
UserSDK.default?.logout(fcmToken: currentFcmToken) { success, error in }
```

After logout, call `setFcmToken(_:)` again if the new (anonymous) user should receive pushes.

---

## In-app messages — custom fonts

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

## Changelog

### 1.0.0
- **BYOT** — removed Firebase and Gifu dependencies. The SDK is now dependency-free.
- Host app provides the FCM token via `init(fcmToken:)`, `setFcmToken(_:)` or `ping(fcmToken:)`.
- `logout(fcmToken:)` now takes the token explicitly.
- In-app GIFs decoded via ImageIO (Gifu removed).
- No automatic notification-permission prompt unless `registerForRemoteNotifications` is called.

### 0.7.x
- In-app message improvements, SPM support, logout/reinstall fixes.

## License

MIT
