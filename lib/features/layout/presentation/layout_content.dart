import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';

class LayoutContent extends StatefulWidget {
  const LayoutContent({super.key});

  @override
  State<LayoutContent> createState() => _LayoutContentState();
}

class _LayoutContentState extends State<LayoutContent> {
  bool _busy = false;
  String _status = '';
  StatusType _statusType = StatusType.info;
  String? _layoutTree;
  bool _prettyPrint = true;
  String _searchQuery = '';
  String _filterType = 'all';
  List<String> _layoutHistory = [];
  int _viewCount = 0;
  int _depth = 0;

  @override
  void initState() {
    super.initState();
    _loadLayoutHistory();
  }

  Future<void> _loadLayoutHistory() async {
    final result = await CliService.run('layout --history');
    if (!mounted || !result.success) return;
    setState(() {
      _layoutHistory = result.output.split('\n').where((l) => l.trim().isNotEmpty).toList();
    });
  }

  Future<void> _getLayout() async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Fetching layout...';
      _statusType = StatusType.loading;
      _layoutTree = null;
    });

    final args = _prettyPrint ? 'layout --pretty' : 'layout';
    final result = await CliService.run(args);
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _layoutTree = result.output;
        _status = 'Layout fetched';
        _statusType = StatusType.success;
        _analyzeLayout(result.output);
        _loadLayoutHistory();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _getLayoutDiff() async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Fetching diff...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('layout --diff');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _layoutTree = result.output;
        _status = 'Diff fetched';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _analyzeLayout(String layout) {
    int count = 0;
    int maxDepth = 0;
    int currentDepth = 0;

    for (final line in layout.split('\n')) {
      if (line.trim().isNotEmpty) {
        count++;
        currentDepth = line.length - line.trimLeft().length;
        if (currentDepth > maxDepth) maxDepth = currentDepth;
      }
    }

    setState(() {
      _viewCount = count;
      _depth = maxDepth;
    });
  }

  String get _filteredLayout {
    if (_layoutTree == null) return '';

    var filtered = _layoutTree!;

    if (_searchQuery.isNotEmpty) {
      final lines = filtered.split('\n');
      filtered = lines.where((l) =>
        l.toLowerCase().contains(_searchQuery.toLowerCase())
      ).join('\n');
    }

    if (_filterType != 'all') {
      final lines = filtered.split('\n');
      filtered = lines.where((l) =>
        l.toLowerCase().contains(_filterType.toLowerCase())
      ).join('\n');
    }

    return filtered;
  }

  void _copyLayout() {
    if (_layoutTree != null) {
      Clipboard.setData(ClipboardData(text: _filteredLayout));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layout copied to clipboard')),
      );
    }
  }

  void _exportLayout() {
    if (_layoutTree != null) {
      final json = '{"layout": ${_layoutTree!.replaceAll('"', '\\"')}}';
      Clipboard.setData(ClipboardData(text: json));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layout exported as JSON')),
      );
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Filter by Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.select_all),
              title: const Text('All Views'),
              trailing: _filterType == 'all' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () { Navigator.pop(context); setState(() => _filterType = 'all'); },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('TextViews'),
              trailing: _filterType == 'textview' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () { Navigator.pop(context); setState(() => _filterType = 'textview'); },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('ImageViews'),
              trailing: _filterType == 'imageview' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () { Navigator.pop(context); setState(() => _filterType = 'imageview'); },
            ),
            ListTile(
              leading: const Icon(Icons.smart_button),
              title: const Text('Buttons'),
              trailing: _filterType == 'button' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () { Navigator.pop(context); setState(() => _filterType = 'button'); },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('EditTexts'),
              trailing: _filterType == 'edittext' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () { Navigator.pop(context); setState(() => _filterType = 'edittext'); },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('RecyclerViews'),
              trailing: _filterType == 'recyclerview' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () { Navigator.pop(context); setState(() => _filterType = 'recyclerview'); },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Layout Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.inventory), title: const Text('Total Views'), trailing: Text('$_viewCount')),
            ListTile(leading: const Icon(Icons.height), title: const Text('Max Depth'), trailing: Text('$_depth')),
            ListTile(leading: const Icon(Icons.history), title: const Text('History Entries'), trailing: Text('${_layoutHistory.length}')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Layout Inspector', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_viewCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$_viewCount views', style: const TextStyle(color: Colors.teal, fontSize: 12)),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: _busy ? null : _showStatsDialog,
                tooltip: 'Statistics',
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
                  decoration: const InputDecoration(
                    hintText: 'Search layout...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  enabled: !_busy,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Badge(
                  label: _filterType != 'all' ? const Text('1', style: TextStyle(fontSize: 10)) : null,
                  child: const Icon(Icons.filter_list),
                ),
                onPressed: _busy ? null : _showFilterSheet,
                tooltip: 'Filter',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _busy ? null : _getLayout,
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.account_tree),
                label: Text(_busy ? 'Loading...' : 'Get Layout'),
              ),
              ElevatedButton.icon(
                onPressed: _busy ? null : _getLayoutDiff,
                icon: const Icon(Icons.compare),
                label: const Text('Get Diff'),
              ),
              OutlinedButton.icon(
                onPressed: _busy || _layoutTree == null ? null : _copyLayout,
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
              OutlinedButton.icon(
                onPressed: _busy || _layoutTree == null ? null : _exportLayout,
                icon: const Icon(Icons.code),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: _prettyPrint,
                onChanged: _busy ? null : (v) => setState(() => _prettyPrint = v),
              ),
              const Text('Pretty Print'),
            ],
          ),
          const SizedBox(height: 12),
          if (_layoutTree != null)
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Layout Tree', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('$_viewCount views • Depth $_depth',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _filteredLayout,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
