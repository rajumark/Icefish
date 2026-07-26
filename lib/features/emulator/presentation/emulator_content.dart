import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Set<String> _running = {};
  bool _loading = true;
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadEmulators();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkRunning());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
      _loading = false;
    });
    _checkRunning();
  }

  Future<void> _checkRunning() async {
    if (!mounted) return;
    final result = await CliService.run('devices');
    if (!mounted) return;

    if (result.success) {
      final running = <String>{};
      for (final line in result.output.split('\n')) {
        if (line.contains('emulator') && line.contains('device')) {
          final id = line.split('\t').first.trim();
          running.add(id);
        }
      }
      setState(() => _running = running);
    }
  }

  bool _isEmulatorRunning(String name) {
    return _running.any((id) => id.contains(name.replaceAll(' ', '_').toLowerCase()));
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
    _checkRunning();
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
    _checkRunning();
  }

  Future<void> _stopAllEmulators() async {
    if (!mounted || _busy) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Stop All Emulators',
      message: 'Stop all running emulators?',
      confirmLabel: 'Stop All',
      confirmColor: Colors.orange,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Stopping all emulators...';
      _statusType = StatusType.loading;
    });

    for (final id in _running) {
      await CliService.run('emulator stop $id');
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = 'All emulators stopped';
      _statusType = StatusType.success;
    });
    _checkRunning();
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

  Future<void> _takeScreenshot() async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Taking screenshot...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('screen capture');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'Screenshot saved: ${result.output.split('to ').last.trim()}';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _installApk(String device) async {
    if (!mounted || _busy) return;

    final controller = TextEditingController();
    final path = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Install APK'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter APK path',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Install'),
          ),
        ],
      ),
    );

    if (path == null || path.isEmpty) return;

    setState(() {
      _busy = true;
      _status = 'Installing APK...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('run --apks=$path --device=$device');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'APK installed';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _getEmulatorInfo(String name) async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Getting info...';
      _statusType = StatusType.loading;
    });

    final device = _running.firstWhere(
      (id) => id.contains(name.replaceAll(' ', '_').toLowerCase()),
      orElse: () => '',
    );

    if (device.isEmpty) {
      setState(() {
        _busy = false;
        _status = '$name is not running';
        _statusType = StatusType.error;
      });
      return;
    }

    final info = StringBuffer();
    await CliService.run('run --device=$device --type=ACTIVITY');
    info.writeln('Device: $device');
    info.writeln('Name: $name');

    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = info.toString();
      _statusType = StatusType.info;
    });
  }

  Future<void> _copyEmulatorId(String id) async {
    await Clipboard.setData(ClipboardData(text: id));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emulator ID copied')),
    );
  }

  void _showEmulatorActions(String name) {
    final isRunning = _isEmulatorRunning(name);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (isRunning) ...[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Take Screenshot'),
                onTap: () {
                  Navigator.pop(context);
                  _takeScreenshot();
                },
              ),
              ListTile(
                leading: const Icon(Icons.install_mobile, color: Colors.blue),
                title: const Text('Install APK'),
                onTap: () {
                  Navigator.pop(context);
                  _installApk(name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.orange),
                title: const Text('Emulator Info'),
                onTap: () {
                  Navigator.pop(context);
                  _getEmulatorInfo(name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.stop_circle, color: Colors.orange),
                title: const Text('Stop Emulator'),
                onTap: () {
                  Navigator.pop(context);
                  _stopEmulator(name);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.green),
                title: const Text('Start Emulator'),
                onTap: () {
                  Navigator.pop(context);
                  _startEmulator(name);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.grey),
              title: const Text('Copy Name'),
              onTap: () {
                Navigator.pop(context);
                _copyEmulatorId(name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Emulator'),
              onTap: () {
                Navigator.pop(context);
                _removeEmulator(name);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final runningCount = _running.length;

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
              if (runningCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$runningCount running', style: const TextStyle(color: Colors.green, fontSize: 12)),
                ),
              ],
              const Spacer(),
              if (runningCount > 0)
                TextButton.icon(
                  onPressed: _busy ? null : _stopAllEmulators,
                  icon: const Icon(Icons.stop_circle, color: Colors.orange, size: 16),
                  label: const Text('Stop All', style: TextStyle(color: Colors.orange)),
                ),
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
                  final isRunning = _isEmulatorRunning(emulator);
                  return Card(
                    child: ListTile(
                      leading: Stack(
                        children: [
                          const Icon(Icons.phone_android),
                          if (isRunning)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(emulator),
                      subtitle: Text(isRunning ? 'Running' : 'Stopped',
                        style: TextStyle(color: isRunning ? Colors.green : Colors.grey, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(isRunning ? Icons.stop : Icons.play_arrow,
                              color: isRunning ? Colors.orange : Colors.green),
                            onPressed: _busy ? null : () => isRunning ? _stopEmulator(emulator) : _startEmulator(emulator),
                            tooltip: isRunning ? 'Stop' : 'Start',
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showEmulatorActions(emulator),
                            tooltip: 'More Actions',
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
