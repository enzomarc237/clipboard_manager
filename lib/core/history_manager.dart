import 'package:clipboard_manager/core/shared_prefs_service.dart';
import '../models/clipboard_item.dart';
import 'clipboard_service.dart';

class HistoryManager {
  static const String _historyKey = 'clipboard_history';
  final ClipboardService _clipboardService = ClipboardService();
  final SharedPrefsService _prefsService = SharedPrefsService();

  Future<List<ClipboardItem>> getHistory() async {
    final historyJson = await _prefsService.getStringList(_historyKey) ?? [];
    return historyJson
        .map((json) => ClipboardItem.fromJson(json))
        .toList()
        .reversed
        .toList(); // Show most recent first
  }

  Future<void> addHistoryItem() async {
    final history = await getHistory();
    final clipBoardContent = await _clipboardService.getClipboardContent();
    final newClipBoardItem = ClipboardItem(text: clipBoardContent, timestamp: DateTime.now());

    if (clipBoardContent == null || clipBoardContent.isEmpty) return;

    if (history.isNotEmpty && history.first.text == clipBoardContent) {
      return;
    }

    List<String> newHistory = [
      newClipBoardItem.toJson(),
      ...history.map((item) => item.toJson())
    ];
    await _prefsService.setStringList(_historyKey, newHistory);
  }

  Future<void> clearHistory() async {
    await _prefsService.remove(_historyKey);
  }

  Future<void> deleteItem(ClipboardItem item) async {
    final history = await getHistory();
    history.removeWhere((historyItem) => historyItem.id == item.id);
    await _prefsService.setStringList(
      _historyKey, history.map((item) => item.toJson()).toList());
  }
}
