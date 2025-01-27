import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error, critical }

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  static const _logFileName = 'clipboard_manager.log';
  
  Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    dynamic error,
    StackTrace? stackTrace,
  }) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final logEntry = '$timestamp [${level.toString().split('.').last.toUpperCase()}] $message';

    // Console logging
    _logToConsole(logEntry, level, error, stackTrace);

    // File logging
    if (!kDebugMode) {
      await _logToFile(logEntry, level, error, stackTrace);
    }
  }

  void _logToConsole(
    String logEntry, 
    LogLevel level, 
    dynamic error, 
    StackTrace? stackTrace
  ) {
    switch (level) {
      case LogLevel.debug:
        debugPrint(logEntry);
        break;
      case LogLevel.info:
        print(logEntry);
        break;
      case LogLevel.warning:
        print('\x1B[33m$logEntry\x1B[0m'); // Yellow
        break;
      case LogLevel.error:
        print('\x1B[31m$logEntry\x1B[0m'); // Red
        if (error != null) print(error);
        if (stackTrace != null) print(stackTrace);
        break;
      case LogLevel.critical:
        print('\x1B[41m$logEntry\x1B[0m'); // Red background
        if (error != null) print(error);
        if (stackTrace != null) print(stackTrace);
        break;
    }
  }

  Future<void> _logToFile(
    String logEntry, 
    LogLevel level, 
    dynamic error, 
    StackTrace? stackTrace
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');

      // Append log entry
      await file.writeAsString('$logEntry\n', mode: FileMode.append);

      // If error or stackTrace, append those
      if (error != null) {
        await file.writeAsString('Error: $error\n', mode: FileMode.append);
      }
      if (stackTrace != null) {
        await file.writeAsString('Stacktrace: $stackTrace\n', mode: FileMode.append);
      }

      // Rotate logs if file gets too large (e.g., > 5MB)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        await _rotateLogs(file);
      }
    } catch (e) {
      print('Failed to write log to file: $e');
    }
  }

  Future<void> _rotateLogs(File currentLogFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final archiveFileName = 'clipboard_manager_$timestamp.log';
    
    // Rename current log file
    await currentLogFile.rename('${directory.path}/$archiveFileName');
  }

  // Retrieve log contents
  Future<List<String>> getLogs({int limit = 100}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      
      if (!await file.exists()) {
        return [];
      }

      // Read logs, return last 'limit' lines
      final lines = await file.readAsLines();
      return lines.length > limit 
        ? lines.sublist(lines.length - limit) 
        : lines;
    } catch (e) {
      print('Error reading log file: $e');
      return [];
    }
  }

  // Clear log file
  Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      
      if (await file.exists()) {
        await file.writeAsString(''); // Clear contents
      }
    } catch (e) {
      print('Error clearing log file: $e');
    }
  }
}

// Global logger instance
final logger = Logger();
