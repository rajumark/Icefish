import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/result_card.dart';

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
              ElevatedButton.icon(
                onPressed: _busy ? null : _getLayout,
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.account_tree),
                label: Text(_busy ? 'Loading...' : 'Get Layout'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _busy ? null : _getLayoutDiff,
                icon: const Icon(Icons.compare),
                label: const Text('Get Diff'),
              ),
              const SizedBox(width: 16),
              Switch(
                value: _prettyPrint,
                onChanged: _busy ? null : (value) => setState(() => _prettyPrint = value),
              ),
              const Text('Pretty'),
            ],
          ),
          const SizedBox(height: 24),
          if (_layoutTree != null)
            Expanded(
              child: ResultCard(title: 'Layout Tree', content: _layoutTree!),
            ),
        ],
      ),
    );
  }
}
