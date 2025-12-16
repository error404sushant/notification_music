package com.binimise.staff.generic_audio_notification

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** GenericAudioNotificationPlugin */
class GenericAudioNotificationPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: android.content.Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "generic_audio_notification")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "startAudio") {
      val url = call.argument<String>("url")
      val title = call.argument<String>("title")
      val body = call.argument<String>("body")
      val icon = call.argument<String>("icon")
      val loop = call.argument<Boolean>("loop") ?: true

      val intent = android.content.Intent(context, AudioService::class.java)
      intent.action = AudioService.ACTION_START
      intent.putExtra(AudioService.EXTRA_URL, url)
      intent.putExtra(AudioService.EXTRA_TITLE, title)
      intent.putExtra(AudioService.EXTRA_BODY, body)
      intent.putExtra(AudioService.EXTRA_ICON, icon)
      intent.putExtra(AudioService.EXTRA_LOOP, loop)

      if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
        context.startForegroundService(intent)
      } else {
        context.startService(intent)
      }
      result.success(null)
    } else if (call.method == "stopAudio") {
      val intent = android.content.Intent(context, AudioService::class.java)
      intent.action = AudioService.ACTION_STOP
      context.startService(intent)
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
