import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/result_card.dart';

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
  final _searchController = TextEditingController();
  final _fetchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _fetchController.dispose();
    super.dispose();
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
                  const Text('Fetch Documentation', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fetchController,
                          decoration: const InputDecoration(
                            hintText: 'Enter documentation URL...',
                            border: OutlineInputBorder(),
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
          const SizedBox(height: 24),
          if (_result != null)
            Expanded(
              child: ResultCard(title: 'Result', content: _result!),
            ),
        ],
      ),
    );
  }
}
