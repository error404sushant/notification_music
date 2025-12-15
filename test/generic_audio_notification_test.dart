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
}

void main() {
  final GenericAudioNotificationPlatform initialPlatform = GenericAudioNotificationPlatform.instance;

  test('$MethodChannelGenericAudioNotification is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGenericAudioNotification>());
  });

  test('getPlatformVersion', () async {
    GenericAudioNotification genericAudioNotificationPlugin = GenericAudioNotification();
    MockGenericAudioNotificationPlatform fakePlatform = MockGenericAudioNotificationPlatform();
    GenericAudioNotificationPlatform.instance = fakePlatform;

    expect(await genericAudioNotificationPlugin.getPlatformVersion(), '42');
  });
}
