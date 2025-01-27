import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import '../core/clipboard_service.dart';
import '../core/history_manager.dart';
import '../core/platform_channel_service.dart';
import '../core/shared_prefs_service.dart';
import '../models/clipboard_item.dart';

class ClipboardProvider with ChangeNotifier {
  final HistoryManager _historyManager = HistoryManager();
  final ClipboardService _clipboardService = ClipboardService();
  final PlatformChannelService _platformChannelService = PlatformChannelService();
  final SharedPrefsService _prefsService = SharedPrefsService();
  final Logger _logger = Logger();

  List<ClipboardItem> _history = [];
  String _searchQuery = "";
  
  // Preferences
  bool _isBackgroundMonitoringEnabled = true;
  int _historySizeLimit = 20;
  bool _autoClearHistoryEnabled = false;
  Duration _autoClearHistoryDuration = const Duration(days: 1);

  static const String _backgroundMonitoringPrefKey = 'background_monitoring_enabled';
  static const String _historySizeLimitPrefKey = 'history_size_limit';
  static const String _autoClearHistoryPrefKey = 'auto_clear_history_enabled';
  static const String _autoClearHistoryDurationPrefKey = 'auto_clear_history_duration';

  bool get isBackgroundMonitoringEnabled => _isBackgroundMonitoringEnabled;
  int get historySizeLimit => _historySizeLimit;
  bool get autoClearHistoryEnabled => _autoClearHistoryEnabled;
  Duration get autoClearHistoryDuration => _autoClearHistoryDuration;

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
      _logger.e('Error initializing clipboard provider', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _loadSettings() async {
    try {
      // Background Monitoring
      final enabled = await _prefsService.getBool(_backgroundMonitoringPrefKey) ?? true;
      _isBackgroundMonitoringEnabled = enabled;

      // History Size Limit
      final historySizeLimit = await _prefsService.getInt(_historySizeLimitPrefKey) ?? 20;
      _historySizeLimit = historySizeLimit;

      // Auto Clear History
      final autoClearHistoryEnabled = await _prefsService.getBool(_autoClearHistoryPrefKey) ?? false;
      _autoClearHistoryEnabled = autoClearHistoryEnabled;

      // Auto Clear History Duration
      final autoClearHistoryDurationStr = await _prefsService.getString(_autoClearHistoryDurationPrefKey);
      if (autoClearHistoryDurationStr != null) {
        _autoClearHistoryDuration = Duration(seconds: int.parse(autoClearHistoryDurationStr));
      }

      _logger.i(
        'Preferences loaded: '
        'Background Monitoring: $_isBackgroundMonitoringEnabled, '
        'History Size: $_historySizeLimit, '
        'Auto Clear: $_autoClearHistoryEnabled, '
        'Clear Duration: $_autoClearHistoryDuration'
      );

      notifyListeners();
    } catch (e) {
      _logger.e('Error loading preferences', error: e);
    }
  }

  Future<void> updateSettings({
    bool? backgroundMonitoring,
    int? historySizeLimit,
    bool? autoClearHistory,
    Duration? autoClearHistoryDuration,
  }) async {
    try {
      // Update background monitoring
      if (backgroundMonitoring != null) {
        await _prefsService.setBool(_backgroundMonitoringPrefKey, backgroundMonitoring);
        _isBackgroundMonitoringEnabled = backgroundMonitoring;
        
        // Start or stop background monitoring based on new setting
        if (backgroundMonitoring) {
          await _initBackgroundMonitoring();
        } else {
          await _stopBackgroundMonitoring();
        }
      }

      // Update history size limit
      if (historySizeLimit != null) {
        await _prefsService.setInt(_historySizeLimitPrefKey, historySizeLimit);
        _historySizeLimit = historySizeLimit;
        _applyHistorySizeLimit();
      }

      // Update auto clear history
      if (autoClearHistory != null) {
        await _prefsService.setBool(_autoClearHistoryPrefKey, autoClearHistory);
        _autoClearHistoryEnabled = autoClearHistory;
      }

      // Update auto clear history duration
      if (autoClearHistoryDuration != null) {
        await _prefsService.setString(_autoClearHistoryDurationPrefKey, autoClearHistoryDuration.inSeconds.toString());
        _autoClearHistoryDuration = autoClearHistoryDuration;
      }

      _logger.i('Preferences updated successfully');

      notifyListeners();
    } catch (e) {
      _logger.e('Error updating preferences', error: e);
    }
  }

  void _applyHistorySizeLimit() {
    if (_history.length > _historySizeLimit) {
      _history = _history.sublist(0, _historySizeLimit);
      _logger.d('Applied history size limit: $_historySizeLimit');
    }
  }

  void _clearOldHistory() {
    final now = DateTime.now();
    _history.removeWhere((item) => 
      now.difference(item.timestamp).compareTo(_autoClearHistoryDuration) > 0
    );
    _logger.d('Cleared old history items');
  }

  Future<void> _loadHistory() async {
    try {
      _history = await _historyManager.getHistory();
      _applyHistorySizeLimit();
      
      if (_autoClearHistoryEnabled) {
        _clearOldHistory();
      }

      _logger.i('Loaded ${_history.length} clipboard history items');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.i('Error loading clipboard history', error: e, stackTrace: stackTrace);
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

      _logger.i('Background monitoring set to: $enabled');
      notifyListeners();
    } catch (e) {
      _logger.i('Error setting background monitoring', error: e);
    }
  }

  Future<void> _initBackgroundMonitoring() async {
    if (!_isBackgroundMonitoringEnabled) {
      _logger.d('Background monitoring is disabled');
      return;
    }

    try {
      if (await _checkPermissions()) {
        await _platformChannelService.startBackgroundMonitoring();
        _logger.i('Background monitoring started successfully');
      } else {
        _logger.w('Background monitoring not started due to insufficient permissions');
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing background monitoring', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _stopBackgroundMonitoring() async {
    try {
      await _platformChannelService.stopBackgroundMonitoring();
      _logger.i('Background monitoring stopped successfully');
    } catch (e) {
      _logger.e('Error stopping background monitoring', error: e);
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        var result = await Permission.notification.request();
        _logger.d('Notification permission request result: $result');
        return result.isGranted;
      }
      return true;
    } catch (e) {
      _logger.e('Error checking permissions', error: e);
      return false;
    }
  }

  String _durationToString(Duration duration) {
    if (duration.inHours < 24) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else {
      return '${duration.inDays ~/ 7} week${duration.inDays ~/ 7 == 1 ? '' : 's'}';
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _logger.d('Search query updated: $query');
    notifyListeners();
  }

  Future<void> addHistoryItemFromNative(String? clipboardContent) async {
    if (clipboardContent == null || clipboardContent.isEmpty) {
      _logger.i('Received empty or null clipboard content');
      return;
    }

    try {
      final newClipBoardItem = ClipboardItem(text: clipboardContent, timestamp: DateTime.now());

      List<ClipboardItem> history = await _historyManager.getHistory();
      if (history.isNotEmpty && history.first.text == newClipBoardItem.text) {
        _logger.i('Duplicate clipboard item, skipping');
        return;
      }

      await _historyManager.addHistoryItemFromNative(newClipBoardItem);
      _logger.i('Added new clipboard item from native: $clipboardContent');

      await _loadHistory();
    } catch (e, stackTrace) {
      _logger.i('Error adding history item from native', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> copyToClipboard(ClipboardItem item) async {
    if (item.text == null || item.text!.isEmpty) {
      _logger.w('Attempted to copy empty or null clipboard item');
      return;
    }

    try {
      await _clipboardService.setClipboardContent(item.text!);
      _logger.i('Copied item to clipboard: ${item.text}');
    } catch (e) {
      _logger.e('Error copying to clipboard', error: e);
    }
  }

  Future<void> deleteHistoryItem(ClipboardItem item) async {
    try {
      await _historyManager.deleteItem(item);
      _logger.i('Deleted clipboard history item: ${item.text}');
      await _loadHistory();
    } catch (e, stackTrace) {
      _logger.e('Error deleting history item', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> clearHistory() async {
    try {
      await _historyManager.clearHistory();
      _logger.i('Cleared entire clipboard history');
      await _loadHistory();
    } catch (e, stackTrace) {
      _logger.e('Error clearing clipboard history', error: e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    try {
      _stopBackgroundMonitoring();
    } catch (e) {
      _logger.w('Error during provider disposal', error: e);
    } finally {
      super.dispose();
    }
  }
}
