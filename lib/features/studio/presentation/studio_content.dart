import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/utils/responsive.dart';
import 'package:icefish/core/widgets/status_banner.dart';

class StudioContent extends StatefulWidget {
  const StudioContent({super.key});

  @override
  State<StudioContent> createState() => _StudioContentState();
}

class _StudioContentState extends State<StudioContent> {
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';
  String? _result;
  List<String> _actionHistory = [];
  Set<String> _favorites = {};
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _findDeclController = TextEditingController();
  final _findUsagesController = TextEditingController();
  final _openFileController = TextEditingController();
  final _analyzeFileController = TextEditingController();
  final _versionLookupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _findDeclController.dispose();
    _findUsagesController.dispose();
    _openFileController.dispose();
    _analyzeFileController.dispose();
    _versionLookupController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final result = await CliService.run('studio --history');
    if (!mounted || !result.success) return;
    setState(() {
      _actionHistory = result.output.split('\n').where((l) => l.trim().isNotEmpty).toList();
    });
  }

  Future<void> _loadFavorites() async {
    final result = await CliService.run('studio --favorites');
    if (!mounted || !result.success) return;
    setState(() {
      _favorites = result.output.split('\n').where((l) => l.trim().isNotEmpty).toSet();
    });
  }

  Future<void> _runAction(String label, String command, [String? input]) async {
    if (input != null && input.isEmpty) {
      setState(() {
        _status = 'Please enter a value';
        _statusType = StatusType.error;
      });
      return;
    }

    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = '$label...';
      _statusType = StatusType.loading;
      _result = null;
    });

    final result = await CliService.run(input != null ? '$command $input' : command);
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _result = result.output;
        _status = '$label complete';
        _statusType = StatusType.success;
        _actionHistory.insert(0, '$label: ${input ?? command}');
        if (_actionHistory.length > 20) _actionHistory.removeLast();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _copyResult() {
    if (_result != null) {
      Clipboard.setData(ClipboardData(text: _result!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result copied')),
      );
    }
  }

  void _toggleFavorite(String action) {
    setState(() {
      if (_favorites.contains(action)) {
        _favorites.remove(action);
      } else {
        _favorites.add(action);
      }
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.blue),
              title: const Text('Build Project'),
              onTap: () { Navigator.pop(context); _runAction('Building', 'studio build'); },
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services, color: Colors.orange),
              title: const Text('Clean Project'),
              onTap: () { Navigator.pop(context); _runAction('Cleaning', 'studio clean'); },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text('Run Project'),
              onTap: () { Navigator.pop(context); _runAction('Running', 'studio run'); },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: const Text('Debug Project'),
              onTap: () { Navigator.pop(context); _runAction('Debugging', 'studio debug'); },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.teal),
              title: const Text('Run Tests'),
              onTap: () { Navigator.pop(context); _runAction('Testing', 'studio test'); },
            ),
            ListTile(
              leading: const Icon(Icons.format_paint, color: Colors.purple),
              title: const Text('Format Code'),
              onTap: () { Navigator.pop(context); _runAction('Formatting', 'studio format'); },
            ),
          ],
        ),
      ),
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Action History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _actionHistory.isEmpty
                  ? const Center(child: Text('No history'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _actionHistory.length,
                      itemBuilder: (context, index) {
                        final item = _actionHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: () {
                              setState(() => _actionHistory.removeAt(index));
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ActionItem> get _allActions => [
    _ActionItem('Find Declaration', 'studio find-declaration', Icons.search, Colors.blue),
    _ActionItem('Find Usages', 'studio find-usages', Icons.find_replace, Colors.teal),
    _ActionItem('Open File', 'studio open-file', Icons.folder_open, Colors.orange),
    _ActionItem('Analyze File', 'studio analyze-file', Icons.analytics, Colors.purple),
    _ActionItem('Version Lookup', 'studio version-lookup', Icons.info_outline, Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.contentPadding(context);
    final spacing = Responsive.cardSpacing(context);

    final filteredActions = _searchQuery.isEmpty
        ? _allActions
        : _allActions.where((a) => a.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Studio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _busy ? null : _showHistorySheet,
                tooltip: 'History',
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _busy ? null : _showQuickActions,
                tooltip: 'Quick Actions',
              ),
            ],
          ),
          SizedBox(height: spacing * 1.5),
          if (_status.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: StatusBanner(
                message: _status,
                type: _statusType,
                onDismiss: () => setState(() => _status = ''),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search actions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              SizedBox(width: spacing * 0.5),
              ElevatedButton.icon(
                onPressed: _busy ? null : () => _runAction('Checking status', 'studio check'),
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle),
                label: const Text('Check'),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Expanded(
            child: ListView.builder(
              itemCount: filteredActions.length,
              itemBuilder: (context, index) {
                final action = filteredActions[index];
                final isFavorite = _favorites.contains(action.title);
                final controller = _getController(action.title);
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(action.icon, color: action.color, size: 20),
                            const SizedBox(width: 8),
                            Text(action.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            IconButton(
                              icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                                color: isFavorite ? Colors.amber : null, size: 20),
                              onPressed: () => _toggleFavorite(action.title),
                              tooltip: 'Favorite',
                            ),
                          ],
                        ),
                        SizedBox(height: spacing * 0.5),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: 'Enter value...',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                enabled: !_busy,
                              ),
                            ),
                            SizedBox(width: spacing * 0.5),
                            ElevatedButton(
                              onPressed: _busy ? null : () => _runAction(action.title, action.command, controller.text.trim()),
                              child: const Text('Run'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_result != null)
            Card(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: _copyResult,
                          tooltip: 'Copy',
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 0.5),
                    SizedBox(
                      height: 120,
                      child: SingleChildScrollView(
                        child: SelectableText(_result!, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  TextEditingController _getController(String title) {
    switch (title) {
      case 'Find Declaration': return _findDeclController;
      case 'Find Usages': return _findUsagesController;
      case 'Open File': return _openFileController;
      case 'Analyze File': return _analyzeFileController;
      case 'Version Lookup': return _versionLookupController;
      default: return TextEditingController();
    }
  }
}

class _ActionItem {
  final String title;
  final String command;
  final IconData icon;
  final Color color;
  _ActionItem(this.title, this.command, this.icon, this.color);
}
