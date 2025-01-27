import 'dart:async';
import 'package:flutter/material.dart';
import '../core/clipboard_service.dart';
import '../core/history_manager.dart';
import '../models/clipboard_item.dart';

class ClipboardProvider with ChangeNotifier {
  final HistoryManager _historyManager = HistoryManager();
  final ClipboardService _clipboardService = ClipboardService();
  List<ClipboardItem> _history = [];
  String _searchQuery = "";
  Timer? _timer;

  List<ClipboardItem> get history => _history.where((item) => 
    item.text?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? true
  ).toList();

  String get searchQuery => _searchQuery;

  ClipboardProvider() {
    _loadHistory();
    startPollingClipboard();
  }

  Future<void> _loadHistory() async {
    _history = await _historyManager.getHistory();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void startPollingClipboard() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateClipboardHistory();
    });
  }

  Future<void> _updateClipboardHistory() async {
    await _historyManager.addHistoryItem();
    await _loadHistory();
  }

  void copyToClipboard(ClipboardItem item) async {
    if (item.text != null) {
      await _clipboardService.setClipboardContent(item.text!);
    }
  }

  void deleteHistoryItem(ClipboardItem item) async {
    await _historyManager.deleteItem(item);
    await _loadHistory();
  }

  void clearHistory() async {
    await _historyManager.clearHistory();
    await _loadHistory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
