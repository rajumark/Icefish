import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';

class DocsContent extends StatefulWidget {
  const DocsContent({super.key});

  @override
  State<DocsContent> createState() => _DocsContentState();
}

class _DocsContentState extends State<DocsContent> {
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';
  String? _result;
  String _searchInResult = '';
  double _fontSize = 13;
  bool _wordWrap = true;
  final _searchController = TextEditingController();
  final _fetchController = TextEditingController();
  final _searchInResultController = TextEditingController();
  List<String> _searchHistory = [];
  List<String> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fetchController.dispose();
    _searchInResultController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final result = await CliService.run('docs --history');
    if (!mounted || !result.success) return;
    setState(() {
      _searchHistory = result.output.split('\n').where((l) => l.trim().isNotEmpty).toList();
    });
  }

  Future<void> _loadBookmarks() async {
    final result = await CliService.run('docs --bookmarks');
    if (!mounted || !result.success) return;
    setState(() {
      _bookmarks = result.output.split('\n').where((l) => l.trim().isNotEmpty).toList();
    });
  }

  Future<void> _searchDocs() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _status = 'Please enter search query';
        _statusType = StatusType.error;
      });
      return;
    }

    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Searching...';
      _statusType = StatusType.loading;
      _result = null;
    });

    final result = await CliService.run('docs search $query');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _result = result.output;
        _status = 'Search complete';
        _statusType = StatusType.success;
        _loadHistory();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _fetchDocs() async {
    final url = _fetchController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _status = 'Please enter URL';
        _statusType = StatusType.error;
      });
      return;
    }

    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Fetching...';
      _statusType = StatusType.loading;
      _result = null;
    });

    final result = await CliService.run('docs fetch $url');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _result = result.output;
        _status = 'Fetch complete';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _copyResult() {
    if (_result != null) {
      Clipboard.setData(ClipboardData(text: _filteredResult));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documentation copied')),
      );
    }
  }

  String get _filteredResult {
    if (_result == null) return '';
    if (_searchInResult.isEmpty) return _result!;
    final lines = _result!.split('\n');
    return lines.where((l) => l.toLowerCase().contains(_searchInResult.toLowerCase())).join('\n');
  }

  void _bookmarkResult() {
    if (_result != null) {
      final title = _searchController.text.isNotEmpty
          ? _searchController.text
          : _fetchController.text;
      if (title.isNotEmpty) {
        _bookmarks.add('$title: ${_result!.substring(0, _result!.length.clamp(0, 50))}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmarked')),
        );
      }
    }
  }

  void _showQuickTopics() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Quick Topics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                ActionChip(
                  avatar: const Icon(Icons.phone_android, size: 16),
                  label: const Text('Emulator'),
                  onPressed: () {
                    Navigator.pop(context);
                    _searchController.text = 'emulator';
                    _searchDocs();
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.build, size: 16),
                  label: const Text('Build Tools'),
                  onPressed: () {
                    Navigator.pop(context);
                    _searchController.text = 'build tools';
                    _searchDocs();
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('ADB'),
                  onPressed: () {
                    Navigator.pop(context);
                    _searchController.text = 'adb';
                    _searchDocs();
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.inventory_2, size: 16),
                  label: const Text('SDK'),
                  onPressed: () {
                    Navigator.pop(context);
                    _searchController.text = 'sdk manager';
                    _searchDocs();
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.settings, size: 16),
                  label: const Text('Gradle'),
                  onPressed: () {
                    Navigator.pop(context);
                    _searchController.text = 'gradle';
                    _searchDocs();
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.code, size: 16),
                  label: const Text('Signing'),
                  onPressed: () {
                    Navigator.pop(context);
                    _searchController.text = 'signing';
                    _searchDocs();
                  },
                ),
              ],
              ),
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
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Search History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _searchHistory.isEmpty
                  ? const Center(child: Text('No history'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        final item = _searchHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.search, size: 16),
                            onPressed: () {
                              Navigator.pop(context);
                              _searchController.text = item;
                              _searchDocs();
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _searchController.text = item;
                            _searchDocs();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarksSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Bookmarks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _bookmarks.isEmpty
                  ? const Center(child: Text('No bookmarks'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _bookmarks.length,
                      itemBuilder: (context, index) {
                        final item = _bookmarks[index];
                        return ListTile(
                          leading: const Icon(Icons.bookmark),
                          title: Text(item, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: () {
                              setState(() => _bookmarks.removeAt(index));
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Documentation', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark),
                onPressed: _busy ? null : _showBookmarksSheet,
                tooltip: 'Bookmarks',
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _busy ? null : _showHistorySheet,
                tooltip: 'History',
              ),
              IconButton(
                icon: const Icon(Icons.topic),
                onPressed: _busy ? null : _showQuickTopics,
                tooltip: 'Quick Topics',
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search Documentation', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search Android docs...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _searchDocs(),
                          enabled: !_busy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _busy ? null : _searchDocs,
                        icon: _busy
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fetch by URL', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fetchController,
                          decoration: const InputDecoration(
                            hintText: 'https://developer.android.com/...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _fetchDocs(),
                          enabled: !_busy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _busy ? null : _fetchDocs,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Fetch'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchInResultController,
                            decoration: const InputDecoration(
                              hintText: 'Find in result...',
                              prefixIcon: Icon(Icons.search, size: 16),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) => setState(() => _searchInResult = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: _copyResult,
                          tooltip: 'Copy',
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_add, size: 20),
                          onPressed: _bookmarkResult,
                          tooltip: 'Bookmark',
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.text_fields, size: 20),
                          onSelected: (v) {
                            if (v == 'wrap') {
                              setState(() => _wordWrap = !_wordWrap);
                            } else if (v == 'bigger') {
                              setState(() => _fontSize = (_fontSize + 1).clamp(10, 24));
                            } else if (v == 'smaller') {
                              setState(() => _fontSize = (_fontSize - 1).clamp(10, 24));
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'wrap', child: Text(_wordWrap ? 'Disable Wrap' : 'Enable Wrap')),
                            const PopupMenuItem(value: 'bigger', child: Text('Increase Font')),
                            const PopupMenuItem(value: 'smaller', child: Text('Decrease Font')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_result != null)
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('${_filteredResult.split('\n').length} lines',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _filteredResult,
                            style: TextStyle(fontSize: _fontSize, fontFamily: _wordWrap ? null : 'monospace'),
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
