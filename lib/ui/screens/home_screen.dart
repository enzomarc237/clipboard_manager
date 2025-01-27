import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/clipboard_provider.dart';
import '../widgets/clipboard_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _searchBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final provider = Provider.of<ClipboardProvider>(context);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Clipboard Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSettingRow(
                    'Background Monitoring',
                    Switch(
                      value: provider.isBackgroundMonitoringEnabled,
                      onChanged: (value) {
                        provider.setBackgroundMonitoringEnabled(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingRow(
                    'History Size Limit',
                    Text('${provider.historySizeLimit} items'),
                    onTap: () => _showHistorySizeLimitDialog(context, provider),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingRow(
                    'Auto Clear History',
                    Switch(
                      value: provider.autoClearHistoryEnabled,
                      onChanged: (value) {
                        provider.updateSettings(autoClearHistory: value);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingRow(
                    'Auto Clear Duration',
                    Text(_durationToString(provider.autoClearHistoryDuration)),
                    onTap: () => _showAutoClearDurationDialog(context, provider),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHistorySizeLimitDialog(BuildContext context, ClipboardProvider provider) {
    final TextEditingController controller = TextEditingController(
      text: provider.historySizeLimit.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History Size Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter maximum number of items',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final limit = int.tryParse(controller.text);
              if (limit != null && limit > 0) {
                provider.updateSettings(historySizeLimit: limit);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAutoClearDurationDialog(BuildContext context, ClipboardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Clear Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Duration>(
              title: const Text('1 Hour'),
              value: const Duration(hours: 1),
              groupValue: provider.autoClearHistoryDuration,
              onChanged: (value) {
                if (value != null) {
                  provider.updateSettings(autoClearHistoryDuration: value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<Duration>(
              title: const Text('1 Day'),
              value: const Duration(days: 1),
              groupValue: provider.autoClearHistoryDuration,
              onChanged: (value) {
                if (value != null) {
                  provider.updateSettings(autoClearHistoryDuration: value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<Duration>(
              title: const Text('1 Week'),
              value: const Duration(days: 7),
              groupValue: provider.autoClearHistoryDuration,
              onChanged: (value) {
                if (value != null) {
                  provider.updateSettings(autoClearHistoryDuration: value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String title, Widget trailing, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  String _durationToString(Duration duration) {
    if (duration.inDays >= 7) {
      return '1 week';
    } else if (duration.inDays >= 1) {
      return '1 day';
    } else {
      return '1 hour';
    }
  }

  @override
  Widget build(BuildContext context) {
    final clipboardProvider = Provider.of<ClipboardProvider>(context);
    final history = clipboardProvider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clipboard Manager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsModal(context),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear all clipboard history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        clipboardProvider.clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Column(
        children: [
          ScaleTransition(
            scale: _searchBarAnimation,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: clipboardProvider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search clipboard history...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          clipboardProvider.setSearchQuery('');
                        },
                      )
                    : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: history.isEmpty 
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.content_paste_off,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No clipboard history yet!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ) 
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
