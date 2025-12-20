# generic_audio_notification

[![pub package](https://img.shields.io/pub/v/generic_audio_notification.svg)](https://pub.dev/packages/generic_audio_notification)

A Flutter package for Android that plays **looping background audio** when a **Firebase Cloud Messaging (FCM)** push notification is received. Perfect for critical alerts that require continuous audio playback until user interaction.

## 🎯 Features

- ✅ **Android-only** support (API 26+)
- ✅ **Looping audio** playback via Android Foreground Service
- ✅ **Configurable loop behavior** - play once or loop continuously
- ✅ **Notification tap callback** - get timestamp when notification is tapped
- ✅ Works in **foreground**, **background**, and **terminated** states
- ✅ Audio stops when user **taps notification** or **opens app**
- ✅ **Data-only FCM messages** (no notification payload needed)
- ✅ Custom notification display
- ✅ Fully reusable package with example app

## 📋 Requirements

- Flutter SDK
- Android SDK (minSdk 26 / Android 8.0+)
- Firebase project with FCM enabled
- `google-services.json` configured

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  generic_audio_notification: ^1.0.0
  firebase_messaging: ^14.7.10
  firebase_core: ^2.24.2
```

Run:
```bash
flutter pub get
```

## 🔧 Setup

### 1. Android Configuration

The package automatically adds required permissions and service declarations. Verify your `android/app/src/main/AndroidManifest.xml` includes:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 2. Firebase Setup

1. Add your `google-services.json` to `android/app/`
2. Add google-services plugin to `android/settings.gradle`:

```gradle
plugins {
    id "com.google.gms.google-services" version "4.4.0" apply false
}
```

3. Apply plugin in `android/app/build.gradle`:

```gradle
plugins {
    id "com.google.gms.google-services"
}
```

### 3. Initialize Firebase

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:generic_audio_notification/generic_audio_notification.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['music_url'] != null) {
    final audio = GenericAudioNotification();
    await audio.startAudio(
      message.data['music_url'],
      title: message.data['title'] ?? 'Alert',
      body: message.data['body'] ?? 'Tap to stop',
      icon: 'mipmap/ic_launcher',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
```

## 📱 Usage

### Register Notification Tap Callback

Get notified when user taps the notification and receive the timestamp:

```dart
GenericAudioNotification().setOnNotificationTapped((timestamp) {
  print('Notification was created at: $timestamp');
  // Use timestamp for analytics, logging, or business logic
  // Audio is automatically stopped when notification is tapped
});
```

### Get FCM Token

```dart
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

### Send FCM Message

Send a **data-only** message (no `notification` object) with high priority:

```json
{
  "message": {
    "token": "YOUR_DEVICE_TOKEN",
    "data": {
      "music_url": "https://example.com/audio.mp3",
      "title": "Critical Alert",
      "body": "Tap to stop audio",
      "should_loop": "true"
    },
    "android": {
      "priority": "high"
    }
  }
}
```

**Important**: 
- Use **data-only** messages (no `notification` payload)
- Set `android.priority` to `"high"` for background delivery
- `music_url` must be a publicly accessible URL
- `should_loop` controls playback: `"true"` for continuous loop (default), `"false"` for single playback

### Stop Audio

```dart
await GenericAudioNotification().stopAudio();
```

## 🎬 How It Works

### Message Flow

1. **FCM Message Received** → Background handler triggered
2. **Audio Service Started** → Foreground service with notification
3. **Audio Loops** → Continuous playback until interaction
4. **User Taps Notification** → App opens, audio stops
5. **User Opens App** → Audio stops automatically

### App States

| State | Handler | Audio Playback |
|-------|---------|----------------|
| **Foreground** | Background handler (Android) | ✅ Works |
| **Background** | Background handler | ✅ Works |
| **Terminated** | Background handler | ✅ Works |

## 📝 FCM Payload Format

### Required Fields

- `music_url` (String): URL to audio file
- `title` (String): Notification title
- `body` (String): Notification body

### Optional Fields

- `should_loop` (String): `"true"` to loop continuously (default), `"false"` to play once

### Example cURL Request

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "DEVICE_TOKEN",
      "data": {
        "music_url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        "title": "Emergency Alert",
        "body": "Tap to acknowledge"
      },
      "android": {
        "priority": "high"
      }
    }
  }'
```

## 🐛 Troubleshooting

### Audio Not Playing

1. **Check logs** for error messages
2. **Verify** `music_url` is publicly accessible
3. **Ensure** FCM message has `android.priority: "high"`
4. **Confirm** app has notification permissions

### Notification Not Showing

1. **Check** notification permissions are granted
2. **Verify** Foreground Service is running (check logs)
3. **Test** with `Simulate Alert` button in example app

### License Issues

**This package no longer requires a license.** All license-related code has been removed.

## 📚 Example App

The package includes a complete example app demonstrating:
- FCM token display with copy button
- Foreground/background message handling
- Notification tap handling
- Audio playback simulation

Run the example:
```bash
cd example
flutter run
```

## 🔍 Logging

The package provides comprehensive logging for debugging:

- `🔧` Setup messages
- `📱` Message received
- `▶️` Audio playback started
- `🛑` Audio stopped
- `✅` Success confirmations
- `⚠️` Warnings

Enable verbose logging in your app to see all events.

## ⚖️ License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/yourusername/generic_audio_notification/issues).

## 🙏 Credits

Created by [Your Name]

---

**Note**: This package is Android-only. iOS support is not planned as iOS has strict background audio limitations.
