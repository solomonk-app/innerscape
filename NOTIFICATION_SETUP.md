# 🔔 Push Notification Setup Guide

Follow these steps to enable push notifications on both iOS and Android.

---

## Android Setup

### 1. Update `android/app/build.gradle`

Make sure your `compileSdkVersion` is 34 or higher:

```gradle
android {
    compileSdkVersion 34
    // ...
}
```

### 2. Add permissions to `android/app/src/main/AndroidManifest.xml`

Add these permissions inside the `<manifest>` tag (before `<application>`):

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### 3. Add receiver inside `<application>` tag:

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

---

## iOS Setup

### 1. Open `ios/Runner.xcworkspace` in Xcode

### 2. Enable Push Notifications capability:
- Select the Runner target
- Go to "Signing & Capabilities"
- Click "+ Capability"
- Add "Push Notifications"
- Add "Background Modes" and check "Remote notifications"

### 3. Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for flutter_local_notifications
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Set minimum iOS version to 12.0+ in `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

---

## Testing Notifications

### Quick Test (Debug)
The app schedules notifications using `matchDateTimeComponents: DateTimeComponents.time`, which repeats daily at the set time. To test quickly:

1. Enable reminders in the app
2. Set the time to 1 minute from now
3. Background the app
4. Wait for the notification

### Things to Note
- Notifications won't show if the app is in the foreground (iOS default behavior)
- On Android 13+, users must explicitly grant notification permission
- The `SCHEDULE_EXACT_ALARM` permission may need user approval on Android 14+
- Notifications survive device restarts thanks to the boot receiver

---

## Notification Content

The app randomly selects from a pool of motivational titles and bodies:

**Titles:**
- "Time to check in 🌙"
- "How are you feeling? ✨"
- "A moment for yourself 🧘"
- "Your journal awaits 📝"
- "Pause. Breathe. Reflect. 🌿"

**Bodies:**
- "Take a moment to reflect on your day and log your mood."
- "A quick check-in can make all the difference."
- "Your future self will thank you for journaling today."
- ...and more

Each notification gets a fresh random combination for variety!
