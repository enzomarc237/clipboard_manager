import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/clipboard_item.dart';
import '../../providers/clipboard_provider.dart';

class ClipboardListItem extends StatelessWidget {
  final ClipboardItem item;

  const ClipboardListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final clipboardProvider = Provider.of<ClipboardProvider>(context);
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(item.timestamp);

    return ListTile(
      title: Text(
        item.text ?? 'Empty Clipboard Item',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(formattedTime),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => clipboardProvider.copyToClipboard(item),
            tooltip: 'Copy to Clipboard',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => clipboardProvider.deleteHistoryItem(item),
            tooltip: 'Delete Item',
          ),
        ],
      ),
    );
  }
}
