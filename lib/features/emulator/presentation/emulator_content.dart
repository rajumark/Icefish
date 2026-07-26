import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

class EmulatorContent extends StatefulWidget {
  const EmulatorContent({super.key});

  @override
  State<EmulatorContent> createState() => _EmulatorContentState();
}

class _EmulatorContentState extends State<EmulatorContent> {
  List<String> _emulators = [];
  bool _loading = true;
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadEmulators();
  }

  Future<void> _loadEmulators() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _status = '';
    });

    final result = await CliService.run('emulator list');
    if (!mounted) return;

    setState(() {
      if (result.success) {
        _emulators = result.output.split('\n').where((e) => e.trim().isNotEmpty).toList();
        _status = '';
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
      _loading = false;
    });
  }

  Future<void> _startEmulator(String name) async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _status = 'Starting $name...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('emulator start $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name started';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _stopEmulator(String name) async {
    if (!mounted || _busy) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Stop Emulator',
      message: 'Stop $name?',
      confirmLabel: 'Stop',
      confirmColor: Colors.orange,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Stopping $name...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('emulator stop $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name stopped';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _removeEmulator(String name) async {
    if (!mounted || _busy) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Remove Emulator',
      message: 'Permanently remove $name?',
      confirmLabel: 'Remove',
      confirmColor: Colors.red,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Removing $name...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('emulator remove $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name removed';
        _statusType = StatusType.success;
        _loadEmulators();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Emulator'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter emulator name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                _createEmulator(name);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createEmulator(String name) async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Creating $name...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('emulator create $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name created';
        _statusType = StatusType.success;
        _loadEmulators();
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
              const Icon(Icons.phone_android, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Emulator', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                onPressed: _loading || _busy ? null : _loadEmulators,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _busy ? null : _showCreateDialog,
                tooltip: 'Create Emulator',
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
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_emulators.isEmpty)
            const Expanded(child: Center(child: Text('No emulators found. Tap + to create one.')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _emulators.length,
                itemBuilder: (context, index) {
                  final emulator = _emulators[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone_android),
                      title: Text(emulator),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.green),
                            onPressed: _busy ? null : () => _startEmulator(emulator),
                            tooltip: 'Start',
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop, color: Colors.orange),
                            onPressed: _busy ? null : () => _stopEmulator(emulator),
                            tooltip: 'Stop',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _busy ? null : () => _removeEmulator(emulator),
                            tooltip: 'Remove',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
