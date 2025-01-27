import 'package:clipboard/clipboard.dart';

class ClipboardService {
  Future<String?> getClipboardContent() async {
    try {
      String? content = await FlutterClipboard.paste();
      return content;
    } catch (e) {
      print('Error accessing clipboard: $e');
      return null;
    }
  }

  Future<void> setClipboardContent(String text) async {
    try {
      await FlutterClipboard.copy(text);
    } catch (e) {
      print('Error setting clipboard: $e');
    }
  }
}
