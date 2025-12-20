import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'generic_audio_notification_method_channel.dart';
import 'notification_response.dart';

abstract class GenericAudioNotificationPlatform extends PlatformInterface {
  /// Constructs a GenericAudioNotificationPlatform.
  GenericAudioNotificationPlatform() : super(token: _token);

  static final Object _token = Object();

  static GenericAudioNotificationPlatform _instance =
      MethodChannelGenericAudioNotification();

  /// The default instance of [GenericAudioNotificationPlatform] to use.
  ///
  /// Defaults to [MethodChannelGenericAudioNotification].
  static GenericAudioNotificationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GenericAudioNotificationPlatform] when
  /// they register themselves.
  static set instance(GenericAudioNotificationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startAudio(
    String url, {
    String? title,
    String? body,
    String? icon,
    bool loop = true,
  }) {
    throw UnimplementedError('startAudio() has not been implemented.');
  }

  Future<void> stopAudio() {
    throw UnimplementedError('stopAudio() has not been implemented.');
  }

  Future<String?> getPackageName() {
    throw UnimplementedError('getPackageName() has not been implemented.');
  }

  void setOnNotificationTapped(
      Function(AudioNotificationResponse response) callback) {
    throw UnimplementedError(
        'setOnNotificationTapped() has not been implemented.');
  }
}
