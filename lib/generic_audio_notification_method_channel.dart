import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'generic_audio_notification_platform_interface.dart';
import 'notification_response.dart';

/// An implementation of [GenericAudioNotificationPlatform] that uses method channels.
class MethodChannelGenericAudioNotification
    extends GenericAudioNotificationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('generic_audio_notification');

  Function(AudioNotificationResponse response)? _onNotificationTapped;

  MethodChannelGenericAudioNotification() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onNotificationTapped') {
      final args = call.arguments as Map;
      final timestamp = args['timestamp'] as int;
      final title = args['title'] as String? ?? '';
      final body = args['body'] as String? ?? '';
      final url = args['url'] as String? ?? '';

      final response = AudioNotificationResponse(
        title: title,
        body: body,
        url: url,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );

      _onNotificationTapped?.call(response);
    }
  }

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

  @override
  Future<String?> getPackageName() async {
    final packageName =
        await methodChannel.invokeMethod<String>('getPackageName');
    return packageName;
  }

  @override
  void setOnNotificationTapped(
      Function(AudioNotificationResponse response) callback) {
    _onNotificationTapped = callback;
  }
}
