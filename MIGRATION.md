# Migration guide — 0.7.x → 1.0.0

Version **1.0.0** removes all external dependencies (Firebase, Gifu). The SDK no longer
initializes Firebase, does not claim the notification-center delegate, and no longer prompts
for notification permission on its own. **You** now own Firebase and provide the FCM token.

This is a breaking change. Existing apps pinned to `0.7.x` keep working — nothing updates until
you bump the version explicitly.

---

## 1. Dependencies

### CocoaPods
Firebase and Gifu are no longer pulled in by the podspec. If your app relies on Firebase for its
own push, **add it to your own Podfile** (you almost certainly already have it):

```ruby
pod 'UserSDK', :git => 'https://github.com/UserEngage/iOS-SDK.git', :tag => '1.0.0'
# your own:
pod 'Firebase/Messaging'
```

### SPM
You no longer need to add Firebase or Gifu as dependencies of the SDK. Remove them **only if they
were added solely for UserSDK** — keep them if your app uses them directly.

---

## 2. FCM token — now provided by you

**Before (0.7.x):** the SDK initialized Firebase and fetched the token automatically.

**Now (1.0.0):** pass the token from your Firebase setup.

```swift
// at init (optional)
let sdk = UserSDK(application: application, apiKey: "...", baseURL: "...",
                  shouldTrackActivities: false, fcmToken: token)

// or later / on refresh
func messaging(_ m: Messaging, didReceiveRegistrationToken token: String?) {
    if let token { UserSDK.default?.setFcmToken(token) }
}

// or carried by a ping
UserSDK.default?.ping(fcmToken: token)
```

> Without a token you can still track users and events — you just won't receive push messages.

---

## 3. Push notification handling

### If you used `registerForRemoteNotifications(...)`
Still works for apps **without** their own push stack — it requests permission, registers APNs,
and makes the SDK the notification-center delegate.

### If you have your own Firebase / push (recommended path)
**Stop calling `registerForRemoteNotifications(...)`** and keep your own delegate. Forward
notifications to the SDK instead:

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

The SDK reacts only to User.com payloads (`user_com_notification`); your own pushes are forwarded
back to your `RemoteNotificationDelegate` untouched. Both work in parallel.

**Bonus:** because the SDK no longer calls `requestAuthorization` for you, the permission prompt
appears only when *you* decide.

---

## 4. Logout — token is now explicit

**Before:**
```swift
UserSDK.default?.logout { success, error in }
```

**Now:**
```swift
UserSDK.default?.logout(fcmToken: currentFcmToken) { success, error in }
```

Pass the token you want to unbind from the logged-out user (or `nil` to skip the delete).
The follow-up anonymous ping carries **no** token — call `setFcmToken(_:)` afterwards if the new
anonymous user should keep receiving pushes.

---

## 5. API summary

| 0.7.x | 1.0.0 |
|-------|-------|
| `UserSDK(application:apiKey:baseURL:shouldTrackActivities:)` | same + optional `fcmToken:` |
| token fetched by SDK (Firebase) | `setFcmToken(_:)` / `ping(fcmToken:)` / `init(fcmToken:)` |
| `logout(_:)` | `logout(fcmToken:_:)` |
| Firebase + Gifu pulled by SDK | zero dependencies (you own Firebase) |

Everything else (`ping`, `sendEvent`, `trackScreen`, `setUserData`, `setCustomUserData`,
product events, in-app messages, `fontResolver`) is unchanged.
