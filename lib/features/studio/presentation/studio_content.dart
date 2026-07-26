import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/result_card.dart';

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
  final _findDeclController = TextEditingController();
  final _findUsagesController = TextEditingController();
  final _openFileController = TextEditingController();
  final _analyzeFileController = TextEditingController();
  final _versionLookupController = TextEditingController();

  @override
  void dispose() {
    _findDeclController.dispose();
    _findUsagesController.dispose();
    _openFileController.dispose();
    _analyzeFileController.dispose();
    _versionLookupController.dispose();
    super.dispose();
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
              const Icon(Icons.code, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Studio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _busy ? null : () => _runAction('Checking status', 'studio check'),
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle),
                label: const Text('Check Status'),
              ),
              ElevatedButton.icon(
                onPressed: _busy ? null : () => _runAction('Rendering preview', 'studio render-compose-preview'),
                icon: const Icon(Icons.preview),
                label: const Text('Compose Preview'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _ActionCard(
                  title: 'Find Declaration',
                  controller: _findDeclController,
                  hintText: 'Enter symbol name...',
                  busy: _busy,
                  onAction: (input) => _runAction('Finding declaration', 'studio find-declaration', input),
                ),
                _ActionCard(
                  title: 'Find Usages',
                  controller: _findUsagesController,
                  hintText: 'Enter symbol name...',
                  busy: _busy,
                  onAction: (input) => _runAction('Finding usages', 'studio find-usages', input),
                ),
                _ActionCard(
                  title: 'Open File',
                  controller: _openFileController,
                  hintText: 'Enter file path...',
                  busy: _busy,
                  actionLabel: 'Open',
                  onAction: (input) => _runAction('Opening file', 'studio open-file', input),
                ),
                _ActionCard(
                  title: 'Analyze File',
                  controller: _analyzeFileController,
                  hintText: 'Enter file path...',
                  busy: _busy,
                  actionLabel: 'Analyze',
                  onAction: (input) => _runAction('Analyzing file', 'studio analyze-file', input),
                ),
                _ActionCard(
                  title: 'Version Lookup',
                  controller: _versionLookupController,
                  hintText: 'Enter artifact name...',
                  busy: _busy,
                  actionLabel: 'Lookup',
                  onAction: (input) => _runAction('Looking up versions', 'studio version-lookup', input),
                ),
              ],
            ),
          ),
          if (_result != null)
            SizedBox(
              height: 200,
              child: ResultCard(title: 'Result', content: _result!),
            ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hintText;
  final bool busy;
  final String actionLabel;
  final Function(String) onAction;

  const _ActionCard({
    required this.title,
    required this.controller,
    required this.hintText,
    required this.busy,
    this.actionLabel = 'Find',
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: const OutlineInputBorder(),
                    ),
                    enabled: !busy,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: busy ? null : () => onAction(controller.text.trim()),
                  child: Text(actionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
