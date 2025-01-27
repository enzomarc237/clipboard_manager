import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/clipboard_provider.dart';
import '../widgets/clipboard_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clipboardProvider = Provider.of<ClipboardProvider>(context);
    final history = clipboardProvider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => clipboardProvider.clearHistory(),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: clipboardProvider.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search ...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: history.isEmpty 
              ? const Center(child: Text("No history yet!")) 
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ClipboardListItem(item: history[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }
}
