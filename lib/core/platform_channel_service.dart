import 'package:flutter/services.dart';
import '../core/logger.dart';

class PlatformChannelService {
  static const _clipboardChannel = MethodChannel('clipboard_manager/clipboard');
  final Logger _logger = Logger();

  Future<void> startBackgroundMonitoring() async {
    try {
      await _clipboardChannel.invokeMethod('startBackgroundMonitoring');
      _logger.log('Background monitoring started', level: LogLevel.info);
    } on PlatformException catch (e) {
      _logger.log('Error starting background monitoring', 
        level: LogLevel.error, 
        error: e, 
        stackTrace: StackTrace.fromString(e.stacktrace!)
      );
    }
  }

  Future<void> stopBackgroundMonitoring() async {
    try {
      await _clipboardChannel.invokeMethod('stopBackgroundMonitoring');
      _logger.log('Background monitoring stopped', level: LogLevel.info);
    } on PlatformException catch (e) {
      _logger.log('Error stopping background monitoring', 
        level: LogLevel.error, 
        error: e, 
        stackTrace: StackTrace.fromString(e.stacktrace!)
      );
    }
  }
}
