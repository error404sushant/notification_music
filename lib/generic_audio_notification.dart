import 'generic_audio_notification_platform_interface.dart';

class GenericAudioNotification {
  static bool _isInitialized = false;

  /// Initialize the plugin (optional - for future use)
  ///
  /// Currently this is optional and the plugin will work without initialization.
  /// This method is kept for backward compatibility and future enhancements.
  ///
  /// Example:
  /// ```dart
  /// await GenericAudioNotification().initialize();
  /// ```
  Future<void> initialize([String? _]) async {
    _isInitialized = true;
  }

  /// Checks if the plugin has been initialized
  bool get isInitialized => _isInitialized;

  Future<String?> getPlatformVersion() {
    return GenericAudioNotificationPlatform.instance.getPlatformVersion();
  }

  Future<void> startAudio(
    String url, {
    String? title,
    String? body,
    String? icon,
    bool loop = true,
  }) {
    return GenericAudioNotificationPlatform.instance.startAudio(
      url,
      title: title,
      body: body,
      icon: icon,
      loop: loop,
    );
  }

  Future<void> stopAudio() {
    return GenericAudioNotificationPlatform.instance.stopAudio();
  }

  /// Set a callback to be invoked when the notification is tapped
  ///
  /// The callback receives a [DateTime] representing when the notification was created.
  /// When the notification is tapped, the audio will automatically stop and the callback
  /// will be invoked with the notification timestamp.
  ///
  /// Example:
  /// ```dart
  /// GenericAudioNotification().setOnNotificationTapped((timestamp) {
  ///   print('Notification tapped! Created at: $timestamp');
  /// });
  /// ```
  void setOnNotificationTapped(Function(DateTime timestamp) callback) {
    GenericAudioNotificationPlatform.instance.setOnNotificationTapped(callback);
  }
}
