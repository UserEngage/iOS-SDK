# Migration guide

## 1.1.x to 1.2.0

No breaking API changes. `setUserData` and `setCustomUserData` gained an optional `fcmToken` parameter with a default value, so existing calls compile unchanged. Two behavior changes are worth checking.

Product event params are separate attributes.

- Before 1.2.0: `sendProductEvent` nested `params` under `custom_data`, which the backend stored as one JSON attribute.
- From 1.2.0: each param is sent next to `custom_id` and becomes its own product attribute, the same as in the Android SDK.
- What to do: if you built segments or automations on the `custom_data` attribute, rebuild them on the individual attributes. Use a fixed set of param keys with stable value types, because every new key creates a new product attribute.

`logout` records a `logout` event.

- From 1.2.0: before wiping the user data, the SDK sends a `logout` event for the user who is leaving.
- What to do: if you already send your own logout event, you may want to remove it to avoid counting logouts twice.

---

## 1.0.0 to 1.1.0

No API changes. Upgrading is a version bump. One behavior change is worth checking.

Completion handlers now report server rejections.

- Before 1.1.0: `sendEvent`, `trackScreen` and similar methods called `completion(true, nil)` even when the server returned an error such as 400 or 401.
- From 1.1.0: a 4xx response calls `completion(false, error)`. A 5xx or a network error is retried with backoff and kept in the queue.

What to do:

- If you treated `true` as proof of delivery, review that logic.
- Nothing else changes. Method names and signatures stay the same.

---

## 0.7.x to 1.0.0

Version 1.0.0 removed all external dependencies (Firebase, Gifu). The SDK no longer initializes Firebase, does not claim the notification-center delegate, and does not prompt for notification permission on its own. You now own Firebase and provide the FCM token.

This is a breaking change. Apps pinned to `0.7.x` keep working until you bump the version.

### 1. Dependencies

CocoaPods. Firebase and Gifu are no longer pulled in by the podspec. If your app uses Firebase for its own push, add it to your own Podfile:

```ruby
pod 'UserSDK', :git => 'https://github.com/UserEngage/iOS-SDK.git', :tag => '1.2.0'
# your own:
pod 'Firebase/Messaging'
```

SPM. You no longer need Firebase or Gifu as dependencies of the SDK. Remove them only if they were added solely for UserSDK. Keep them if your app uses them directly.

### 2. FCM token, now provided by you

- Before (0.7.x): the SDK initialized Firebase and fetched the token.
- Now: you pass the token from your Firebase setup.

```swift
// at init (optional)
let sdk = UserSDK(application: application, apiKey: "...", baseURL: "...",
                  shouldTrackActivities: false, fcmToken: token)

// or later, on refresh
func messaging(_ m: Messaging, didReceiveRegistrationToken token: String?) {
    if let token { UserSDK.default?.setFcmToken(token) }
}

// or carried by a ping
UserSDK.default?.ping(fcmToken: token)
```

Without a token you can still track users and events. You just do not receive push messages.

### 3. Push notification handling

If you used `registerForRemoteNotifications(...)`. It still works for apps without their own push stack. It requests permission, registers APNs, and makes the SDK the notification-center delegate.

If you have your own Firebase or push (recommended). Stop calling `registerForRemoteNotifications(...)` and keep your own delegate. Forward notifications to the SDK:

```swift
UNUserNotificationCenter.current().delegate = self   // your delegate

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

The SDK reacts only to User.com payloads (`user_com_notification`). Your own pushes are forwarded back to your `RemoteNotificationDelegate`. Both work in parallel.

Because the SDK no longer calls `requestAuthorization` for you, the permission prompt appears only when you decide.

### 4. Logout, token is now explicit

Before:
```swift
UserSDK.default?.logout { success, error in }
```

Now:
```swift
UserSDK.default?.logout(fcmToken: currentFcmToken) { success, error in }
```

Pass the token you want to unbind from the logged-out user, or `nil` to skip the delete. The follow-up anonymous ping carries no token. Call `setFcmToken(_:)` afterwards if the new anonymous user should receive pushes.

### 5. API summary

| 0.7.x | 1.0.0 and later |
|-------|-----------------|
| `UserSDK(application:apiKey:baseURL:shouldTrackActivities:)` | same, plus optional `fcmToken:` |
| token fetched by SDK (Firebase) | `setFcmToken(_:)`, `ping(fcmToken:)`, `init(fcmToken:)` |
| `logout(_:)` | `logout(fcmToken:_:)` |
| Firebase and Gifu pulled by SDK | zero dependencies, you own Firebase |

Everything else is unchanged: `ping`, `sendEvent`, `trackScreen`, `setUserData`, `setCustomUserData`, product events, in-app messages, `fontResolver`.
