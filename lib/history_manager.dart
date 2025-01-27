import 'package:shared_preferences/shared_preferences.dart';
import 'clipboard_service.dart';

class HistoryManager {
  static const String _historyKey = 'clipboard_history';
  final ClipboardService _clipboardService = ClipboardService();

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    return historyJson.reversed.toList(); // Show most recent first
  }

  Future<void> addHistoryItem() async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    final clipBoardContent = await _clipboardService.getClipboardContent();

    if (clipBoardContent == null || clipBoardContent.isEmpty) return;

    if (history.isNotEmpty && history.first == clipBoardContent) {
      return;
    }

    List<String> newHistory = [clipBoardContent, ...history];
    await prefs.setStringList(_historyKey, newHistory);
    }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> deleteItem(String item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.remove(item);
    await prefs.setStringList(_historyKey, history);
  }
}
