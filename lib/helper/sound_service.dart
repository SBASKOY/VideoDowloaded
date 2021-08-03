
import 'package:flutter/services.dart';

class SoundService {
  static const MethodChannel _channel = const MethodChannel('com.example.dowloandvideo/channel');
  static const EventChannel _eventChannel = const EventChannel('com.example.dowloandvideo/stream');



  static void getDuration() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      print("FLUTTER MESSAGE---- Event:  $event");
    });
  }

  static Future<bool?> startMusic(String path) async {
    bool? result = await _channel.invokeMethod('startMusic', {"path": path});
    return result;
  }

  static Future<bool?> stopMusic() async {
    bool? result = await _channel.invokeMethod('stopMusic');
    return result;
  }

  static Future<bool?> pauseMusic() async {
    bool? result = await _channel.invokeMethod('pauseMusic');
    return result;
  }

  static Future<bool?> resumeMusic() async {
    bool? result = await _channel.invokeMethod('resumeMusic');
    return result;
  }
}
