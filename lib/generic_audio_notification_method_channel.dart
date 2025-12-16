import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'generic_audio_notification_platform_interface.dart';

/// An implementation of [GenericAudioNotificationPlatform] that uses method channels.
class MethodChannelGenericAudioNotification
    extends GenericAudioNotificationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('generic_audio_notification');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> startAudio(
    String url, {
    String? title,
    String? body,
    String? icon,
    bool loop = true,
  }) async {
    await methodChannel.invokeMethod('startAudio', {
      'url': url,
      'title': title,
      'body': body,
      'icon': icon,
      'loop': loop,
    });
  }

  @override
  Future<void> stopAudio() async {
    await methodChannel.invokeMethod('stopAudio');
  }
}
