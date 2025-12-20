import 'package:flutter_test/flutter_test.dart';
import 'package:generic_audio_notification/generic_audio_notification.dart';
import 'package:generic_audio_notification/generic_audio_notification_platform_interface.dart';
import 'package:generic_audio_notification/generic_audio_notification_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGenericAudioNotificationPlatform
    with MockPlatformInterfaceMixin
    implements GenericAudioNotificationPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> startAudio(String url,
          {String? title, String? body, String? icon, bool loop = true}) =>
      Future.value();

  @override
  Future<void> stopAudio() => Future.value();

  @override
  Future<String?> getPackageName() => Future.value('com.test.package');

  @override
  void setOnNotificationTapped(Function(AudioNotificationResponse response) callback) {
    // Mock implementation - does nothing in tests
  }
}

void main() {
  final GenericAudioNotificationPlatform initialPlatform =
      GenericAudioNotificationPlatform.instance;

  test('$MethodChannelGenericAudioNotification is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelGenericAudioNotification>());
  });

  test('getPlatformVersion', () async {
    GenericAudioNotification genericAudioNotificationPlugin =
        GenericAudioNotification();
    MockGenericAudioNotificationPlatform fakePlatform =
        MockGenericAudioNotificationPlatform();
    GenericAudioNotificationPlatform.instance = fakePlatform;

    expect(await genericAudioNotificationPlugin.getPlatformVersion(), '42');
  });
}
