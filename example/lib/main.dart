import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:generic_audio_notification/generic_audio_notification.dart';

import 'firebase_options.dart';

// ============================================================================
// BACKGROUND MESSAGE HANDLER
// ============================================================================
// This handler is called when:
// 1. App is TERMINATED (completely closed)
// 2. App is in BACKGROUND (minimized)
// 3. App is in FOREGROUND (for data-only messages on Android)
//
// NOTE: This runs in a separate isolate, so it cannot access app state
// ============================================================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('╔════════════════════════════════════════════════════════════════╗');
  print('║          BACKGROUND MESSAGE HANDLER TRIGGERED                  ║');
  print('╚════════════════════════════════════════════════════════════════╝');
  print('📱 Message ID: ${message.messageId}');
  print('📊 Sent Time: ${message.sentTime}');
  print('🔔 Notification: ${message.notification?.title ?? "null"}');
  print('📦 Data payload: ${message.data}');
  print('');

  if (message.data.isNotEmpty) {
    final musicUrl = message.data['music_url'];
    final title = message.data['title'] ?? 'Critical Alert';
    final body = message.data['body'] ?? 'Action Required';

    print('🎵 Music URL found: $musicUrl');
    print('📝 Title: $title');
    print('📝 Body: $body');

    if (musicUrl != null && musicUrl.isNotEmpty) {
      print('▶️  Starting audio playback from background handler...');

      final audio = GenericAudioNotification();
      await audio.startAudio(
        musicUrl,
        title: title,
        body: body,
        icon: 'mipmap/ic_launcher',
      );

      print('✅ Audio service started successfully');
    } else {
      print('⚠️  No valid music_url in data payload');
    }
  } else {
    print('⚠️  Message data is empty');
  }

  print(
      '═══════════════════════════════════════════════════════════════════\n');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _genericAudioNotificationPlugin = GenericAudioNotification();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  String _statusMessage = 'Fetching FCM Token...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initNotifications();
    _requestPermissions();
    _getToken();
    _setupForegroundMessageListener();
    // Stop audio on startup (in case app was launched from notification)
    _genericAudioNotificationPlugin.stopAudio();
  }

  // ==========================================================================
  // FOREGROUND MESSAGE LISTENER
  // ==========================================================================
  // This listener is called when a message arrives while the app is in the
  // FOREGROUND (app is open and visible).
  //
  // NOTE: On Android, data-only messages may NOT trigger this listener.
  // They go directly to the background handler instead.
  // ==========================================================================
  void _setupForegroundMessageListener() {
    print('🔧 Setting up foreground message listener...');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          '\n╔════════════════════════════════════════════════════════════════╗');
      print(
          '║          FOREGROUND MESSAGE RECEIVED                           ║');
      print(
          '╚════════════════════════════════════════════════════════════════╝');
      print('📱 Message ID: ${message.messageId}');
      print('📊 Sent Time: ${message.sentTime}');
      print('🔔 Notification Title: ${message.notification?.title ?? "null"}');
      print('🔔 Notification Body: ${message.notification?.body ?? "null"}');
      print('📦 Data payload: ${message.data}');
      print('');

      if (message.data.isNotEmpty) {
        final musicUrl = message.data['music_url'];
        final title = message.data['title'] ??
            message.notification?.title ??
            'Critical Alert';
        final body = message.data['body'] ??
            message.notification?.body ??
            'Action Required';

        print('🎵 Music URL: $musicUrl');
        print('📝 Title: $title');
        print('📝 Body: $body');

        if (musicUrl != null && musicUrl.isNotEmpty) {
          print('▶️  Starting audio from foreground handler...');
          _genericAudioNotificationPlugin.startAudio(
            musicUrl,
            title: title,
            body: body,
            icon: 'mipmap/ic_launcher',
          );
          print('✅ Audio service started');
        } else {
          print('⚠️  No music_url in data');
        }
      } else {
        print('⚠️  Message data is empty');
      }
      print(
          '═══════════════════════════════════════════════════════════════════\n');
    });

    // ==========================================================================
    // NOTIFICATION TAP HANDLER (when app was in background/terminated)
    // ==========================================================================
    // This is called when user taps a notification that was shown while the
    // app was in the background or terminated state.
    // ==========================================================================
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          '\n╔════════════════════════════════════════════════════════════════╗');
      print(
          '║     NOTIFICATION TAPPED (App was Background/Terminated)        ║');
      print(
          '╚════════════════════════════════════════════════════════════════╝');
      print('📱 Message ID: ${message.messageId}');
      print('📦 Data: ${message.data}');
      print('🛑 Stopping audio (user opened app from notification)...');

      _genericAudioNotificationPlugin.stopAudio();

      print('✅ Audio stopped');
      print(
          '═══════════════════════════════════════════════════════════════════\n');
    });

    // Check if app was opened from a terminated state by tapping notification
    _checkInitialMessage();

    print('✅ Foreground message listener setup complete\n');
  }

  // ==========================================================================
  // CHECK INITIAL MESSAGE
  // ==========================================================================
  // This checks if the app was launched by tapping a notification while it
  // was in TERMINATED state (completely closed).
  // ==========================================================================
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print(
          '\n╔════════════════════════════════════════════════════════════════╗');
      print(
          '║        APP LAUNCHED FROM NOTIFICATION (Terminated State)       ║');
      print(
          '╚════════════════════════════════════════════════════════════════╝');
      print('📱 Message ID: ${initialMessage.messageId}');
      print('📦 Data: ${initialMessage.data}');
      print('🛑 Stopping audio (app launched from notification)...');

      _genericAudioNotificationPlugin.stopAudio();

      print('✅ Audio stopped');
      print(
          '═══════════════════════════════════════════════════════════════════\n');
    }
  }

  Future<void> _getToken() async {
    try {
      // Request notification permission
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('Notification permission status: ${settings.authorizationStatus}');

      final token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _fcmToken = token;
        _statusMessage = token != null ? 'Token Received' : 'Token is null';
      });
      print("FCM Token: $_fcmToken");
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching token: $e';
      });
      print("Error getting token: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _genericAudioNotificationPlugin.stopAudio();
    }
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _genericAudioNotificationPlugin.stopAudio();
      },
    );
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Generic Audio Notification'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_fcmToken != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('FCM Token:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SelectableText(
                          _fcmToken!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _fcmToken!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Token copied to clipboard')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Token'),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_statusMessage, textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 20),
                const Text('Waiting for FCM messages...'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Simulate receiving a message
                    _genericAudioNotificationPlugin.startAudio(
                      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                      title: 'Test Alert',
                      body: 'Click to stop audio',
                      icon: 'mipmap/ic_launcher',
                    );
                  },
                  child: const Text('Simulate Alert'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _genericAudioNotificationPlugin.stopAudio();
                  },
                  child: const Text('Stop Audio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
