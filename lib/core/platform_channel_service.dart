import 'package:flutter/services.dart';

class PlatformChannelService {
  static const _clipboardChannel = MethodChannel('clipboard_manager/clipboard');

  Future<void> startBackgroundMonitoring() async {
    try {
      await _clipboardChannel.invokeMethod('startBackgroundMonitoring');
    } on PlatformException catch(e) {
      print('Failed to start background monitoring: ${e.message}');
    }
  }

  Future<void> stopBackgroundMonitoring() async {
    try {
      await _clipboardChannel.invokeMethod('stopBackgroundMonitoring');
    } on PlatformException catch(e) {
      print('Failed to stop background monitoring: ${e.message}');
    }
  }
}
