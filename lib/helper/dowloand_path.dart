import 'dart:io';

import 'package:flutter/services.dart';

class DownloadsPathProvider {
  static const MethodChannel _channel = const MethodChannel('com.example.dowloandvideo/dowloandDirectiory');

  static Future<Directory?> get downloadsDirectory async {
    final String? path = await _channel.invokeMethod('getDowloandDirectory');
    if (path == null) return null;
    return Directory(path);
  }
    static Future<Directory?> get musicDirectory async {
    final String? path = await _channel.invokeMethod('getMusicDirectory');
    if (path == null) return null;
    return Directory(path);
  }
  
}
