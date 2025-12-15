
import 'generic_audio_notification_platform_interface.dart';

class GenericAudioNotification {
  Future<String?> getPlatformVersion() {
    return GenericAudioNotificationPlatform.instance.getPlatformVersion();
  }

  Future<void> startAudio(String url, {String title = 'Alert', String body = 'Playing audio...', String? icon}) {
    return GenericAudioNotificationPlatform.instance.startAudio(url, title: title, body: body, icon: icon);
  }

  Future<void> stopAudio() {
    return GenericAudioNotificationPlatform.instance.stopAudio();
  }
}
