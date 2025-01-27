import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/clipboard_service.dart';
import '../core/history_manager.dart';
import '../core/platform_channel_service.dart';
import '../core/shared_prefs_service.dart';
import '../core/logger.dart';
import '../models/clipboard_item.dart';

class ClipboardProvider with ChangeNotifier {
  final HistoryManager _historyManager = HistoryManager();
  final ClipboardService _clipboardService = ClipboardService();
  final PlatformChannelService _platformChannelService = PlatformChannelService();
  final SharedPrefsService _prefsService = SharedPrefsService();
  final Logger _logger = Logger();

  List<ClipboardItem> _history = [];
  String _searchQuery = "";
  bool _isBackgroundMonitoringEnabled = true;
  static const String _backgroundMonitoringPrefKey = 'background_monitoring_enabled';
  
  bool get isBackgroundMonitoringEnabled => _isBackgroundMonitoringEnabled;

  List<ClipboardItem> get history =>
      _history
          .where((item) => item.text
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
              true)
          .toList();

  String get searchQuery => _searchQuery;

  ClipboardProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    try {
      await _loadSettings();
      await _loadHistory();
      await _initBackgroundMonitoring();
    } catch (e, stackTrace) {
      _logger.log(
        'Error initializing clipboard provider', 
        level: LogLevel.critical, 
        error: e, 
        stackTrace: stackTrace
      );
    }
  }

  Future<void> _loadSettings() async {
    try {
      final enabled = await _prefsService.getBool(_backgroundMonitoringPrefKey) ?? true;
      _isBackgroundMonitoringEnabled = enabled;
      _logger.log('Background monitoring loaded: $_isBackgroundMonitoringEnabled');
      notifyListeners();
    } catch (e) {
      _logger.log(
        'Error loading background monitoring settings', 
        level: LogLevel.error, 
        error: e
      );
    }
  }

  Future<void> setBackgroundMonitoringEnabled(bool enabled) async {
    try {
      await _prefsService.setBool(_backgroundMonitoringPrefKey, enabled);
      _isBackgroundMonitoringEnabled = enabled;
      
      if (enabled) {
        await _initBackgroundMonitoring();
      } else {
        await _stopBackgroundMonitoring();
      }
      
      _logger.log('Background monitoring set to: $enabled');
      notifyListeners();
    } catch (e) {
      _logger.log(
        'Error setting background monitoring', 
        level: LogLevel.error, 
        error: e
      );
    }
  }

  Future<void> _initBackgroundMonitoring() async {
    if (!_isBackgroundMonitoringEnabled) {
      _logger.log('Background monitoring is disabled');
      return;
    }

    try {
      if (await _checkPermissions()) {
        await _platformChannelService.startBackgroundMonitoring();
        _logger.log('Background monitoring started successfully');
      } else {
        _logger.log(
          'Background monitoring not started due to insufficient permissions', 
          level: LogLevel.warning
        );
      }
    } catch (e, stackTrace) {
      _logger.log(
        'Error initializing background monitoring', 
        level: LogLevel.critical, 
        error: e, 
        stackTrace: stackTrace
      );
    }
  }

  Future<void> _stopBackgroundMonitoring() async {
    try {
      await _platformChannelService.stopBackgroundMonitoring();
      _logger.log('Background monitoring stopped successfully');
    } catch (e) {
      _logger.log(
        'Error stopping background monitoring', 
        level: LogLevel.error, 
        error: e
      );
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        var result = await Permission.notification.request();
        _logger.log('Notification permission request result: $result');
        return result.isGranted;
      }
      return true;
    } catch (e) {
      _logger.log(
        'Error checking permissions', 
        level: LogLevel.error, 
        error: e
      );
      return false;
    }
  }

  Future<void> _loadHistory() async {
    try {
      _history = await _historyManager.getHistory();
      _logger.log('Loaded ${_history.length} clipboard history items');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.log(
        'Error loading clipboard history', 
        level: LogLevel.critical, 
        error: e, 
        stackTrace: stackTrace
      );
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _logger.log('Search query updated: $query');
    notifyListeners();
  }

  Future<void> addHistoryItemFromNative(String? clipboardContent) async {
    if (clipboardContent == null || clipboardContent.isEmpty) {
      _logger.log(
        'Received empty or null clipboard content', 
        level: LogLevel.debug
      );
      return;
    }

    try {
      final newClipBoardItem = ClipboardItem(text: clipboardContent, timestamp: DateTime.now());
      
      List<ClipboardItem> history = await _historyManager.getHistory();
      if (history.isNotEmpty && history.first.text == newClipBoardItem.text) {
        _logger.log('Duplicate clipboard item, skipping', level: LogLevel.debug);
        return;
      }
      
      await _historyManager.addHistoryItemFromNative(newClipBoardItem);
      _logger.log('Added new clipboard item from native: $clipboardContent');
      
      await _loadHistory();
    } catch (e, stackTrace) {
      _logger.log(
        'Error adding history item from native', 
        level: LogLevel.error, 
        error: e, 
        stackTrace: stackTrace
      );
    }
  }

  Future<void> copyToClipboard(ClipboardItem item) async {
    if (item.text == null || item.text!.isEmpty) {
      _logger.log(
        'Attempted to copy empty or null clipboard item', 
        level: LogLevel.warning
      );
      return;
    }

    try {
      await _clipboardService.setClipboardContent(item.text!);
      _logger.log('Copied item to clipboard: ${item.text}');
    } catch (e) {
      _logger.log(
        'Error copying to clipboard', 
        level: LogLevel.error, 
        error: e
      );
    }
  }

  Future<void> deleteItem(ClipboardItem? item) async {
    if (item == null) {
      _logger.log(
        'Attempted to delete null clipboard item', 
        level: LogLevel.warning
      );
      return;
    }

    try {
      await _historyManager.deleteItem(item);
      _logger.log('Deleted clipboard item: ${item.text}');
      await _loadHistory();
    } catch (e, stackTrace) {
      _logger.log(
        'Error deleting history item', 
        level: LogLevel.error, 
        error: e, 
        stackTrace: stackTrace
      );
    }
  }

  Future<void> deleteHistoryItem(ClipboardItem item) async {
    try {
      await _historyManager.deleteItem(item);
      _logger.log('Deleted clipboard history item: ${item.text}');
      await _loadHistory();
    } catch (e, stackTrace) {
      _logger.log(
        'Error deleting history item', 
        level: LogLevel.error, 
        error: e, 
        stackTrace: stackTrace
      );
    }
  }

  Future<void> clearHistory() async {
    try {
      await _historyManager.clearHistory();
      _logger.log('Cleared entire clipboard history');
      await _loadHistory();
    } catch (e, stackTrace) {
      _logger.log(
        'Error clearing clipboard history', 
        level: LogLevel.error, 
        error: e, 
        stackTrace: stackTrace
      );
    }
  }

  @override
  void dispose() {
    try {
      _stopBackgroundMonitoring();
    } catch (e) {
      _logger.log(
        'Error during provider disposal', 
        level: LogLevel.warning, 
        error: e
      );
    } finally {
      super.dispose();
    }
  }
}
