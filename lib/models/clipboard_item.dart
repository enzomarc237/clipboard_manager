import 'package:uuid/uuid.dart';

class ClipboardItem {
  final String id;
  final String? text;
  final DateTime timestamp;

  ClipboardItem({String? id, this.text, required this.timestamp})
      : id = id ?? const Uuid().v4();

  factory ClipboardItem.fromJson(String jsonString) {
    final parts = jsonString.split('|||'); // Using a simple delimiter
    if (parts.length != 3) {
      throw const FormatException("Invalid json string");
    }
    return ClipboardItem(
      id: parts[0],
      text: parts[1],
      timestamp: DateTime.parse(parts[2]),
    );
  }

  String toJson() {
    return '$id|||$text|||${timestamp.toIso8601String()}';
  }
}
