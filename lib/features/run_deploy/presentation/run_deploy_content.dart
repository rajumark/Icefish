import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/utils/responsive.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

class RunDeployContent extends StatefulWidget {
  const RunDeployContent({super.key});

  @override
  State<RunDeployContent> createState() => _RunDeployContentState();
}

class _RunDeployContentState extends State<RunDeployContent> {
  bool _busy = false;
  bool _loadingDevices = true;
  StatusType _statusType = StatusType.info;
  String _status = '';
  bool _debugMode = true;
  bool _uninstallFirst = false;
  bool _clearData = false;
  bool _grantPermissions = true;
  String _selectedDevice = '';
  String _buildVariant = 'debug';
  List<String> _devices = [];
  List<Map<String, dynamic>> _history = [];
  final _apksController = TextEditingController();
  final _activityController = TextEditingController();
  final _typeController = TextEditingController();
  final _packageNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _loadHistory();
  }

  @override
  void dispose() {
    _apksController.dispose();
    _activityController.dispose();
    _typeController.dispose();
    _packageNameController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    if (!mounted) return;
    setState(() => _loadingDevices = true);

    final result = await CliService.run('devices');
    if (!mounted) return;

    if (result.success) {
      final devices = <String>[];
      for (final line in result.output.split('\n')) {
        if (line.contains('\tdevice')) {
          final id = line.split('\t').first.trim();
          devices.add(id);
        }
      }
      setState(() {
        _devices = devices;
        _loadingDevices = false;
        if (devices.isNotEmpty && _selectedDevice.isEmpty) {
          _selectedDevice = devices.first;
        }
      });
    } else {
      setState(() => _loadingDevices = false);
    }
  }

  Future<void> _loadHistory() async {
    final result = await CliService.run('run --type=ACTIVITY');
    if (!mounted) return;

    if (result.success && result.output.isNotEmpty) {
      try {
        final List<dynamic> json = jsonDecode(result.output);
        setState(() => _history = json.cast<Map<String, dynamic>>());
      } catch (_) {}
    }
  }

  Future<void> _saveToHistory(String apk, String device) async {
    final entry = {
      'apk': apk,
      'device': device,
      'debug': _debugMode,
      'variant': _buildVariant,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _history.removeWhere((h) => h['apk'] == apk && h['device'] == device);
    _history.insert(0, entry);
    if (_history.length > 10) _history.removeLast();
  }

  Future<void> _runApp() async {
    final apks = _apksController.text.trim();
    if (apks.isEmpty) {
      setState(() {
        _status = 'Please enter APK path';
        _statusType = StatusType.error;
      });
      return;
    }

    if (!mounted || _busy) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Deploy App',
      message: 'Deploy to ${_selectedDevice.isEmpty ? "default device" : _selectedDevice}?',
      confirmLabel: 'Deploy',
      confirmColor: Colors.green,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Deploying app...';
      _statusType = StatusType.loading;
    });

    if (_uninstallFirst && _packageNameController.text.isNotEmpty) {
      setState(() => _status = 'Uninstalling old app...');
      await CliService.run('run --uninstall=${_packageNameController.text} --device=$_selectedDevice');
    }

    if (_clearData && _packageNameController.text.isNotEmpty) {
      setState(() => _status = 'Clearing app data...');
      await CliService.run('run --clear-data --device=$_selectedDevice');
    }

    final args = StringBuffer('run --apks=$apks');
    if (_debugMode) args.write(' --debug');
    if (_selectedDevice.isNotEmpty) args.write(' --device=$_selectedDevice');
    if (_activityController.text.isNotEmpty) args.write(' --activity=${_activityController.text}');
    if (_typeController.text.isNotEmpty) args.write(' --type=${_typeController.text}');

    setState(() => _status = 'Installing APK...');
    final result = await CliService.run(args.toString());
    if (!mounted) return;

    if (result.success && _grantPermissions && _packageNameController.text.isNotEmpty) {
      setState(() => _status = 'Granting permissions...');
      await CliService.run('run --grant-all --package=${_packageNameController.text} --device=$_selectedDevice');
    }

    if (result.success) {
      await _saveToHistory(apks, _selectedDevice);
    }

    setState(() {
      _busy = false;
      if (result.success) {
        _status = result.output.isNotEmpty ? result.output : 'App deployed successfully';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _buildApp() async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Building app ($_buildVariant)...';
      _statusType = StatusType.loading;
    });

    final buildCmd = _buildVariant == 'release' ? 'build apk --release' : 'build apk --debug';
    final result = await CliService.run('run --build=$buildCmd');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'Build complete';
        _statusType = StatusType.success;
        _apksController.text = 'build/app/outputs/flutter-apk/app-$_buildVariant.apk';
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _selectApkFile() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select APK'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter APK path',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                ActionChip(
                  label: const Text('app-debug.apk', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    controller.text = 'build/app/outputs/flutter-apk/app-debug.apk';
                  },
                ),
                ActionChip(
                  label: const Text('app-release.apk', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    controller.text = 'build/app/outputs/flutter-apk/app-release.apk';
                  },
                ),
                ActionChip(
                  label: const Text('app-profile.apk', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    controller.text = 'build/app/outputs/flutter-apk/app-profile.apk';
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final path = controller.text.trim();
              if (path.isNotEmpty) {
                Navigator.pop(context);
                _apksController.text = path;
              }
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
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
              title: const Text('Build & Run'),
              subtitle: const Text('Build APK then deploy'),
              onTap: () {
                Navigator.pop(context);
                _buildAndRun();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services, color: Colors.orange),
              title: const Text('Clear App Data'),
              subtitle: Text(_packageNameController.text.isNotEmpty
                  ? _packageNameController.text
                  : 'Enter package name first'),
              onTap: () {
                Navigator.pop(context);
                _clearAppData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.screenshot, color: Colors.teal),
              title: const Text('Take Screenshot'),
              subtitle: const Text('Capture device screen'),
              onTap: () {
                Navigator.pop(context);
                _takeScreenshot();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.purple),
              title: const Text('Device Info'),
              subtitle: const Text('Show connected device details'),
              onTap: () {
                Navigator.pop(context);
                _showDeviceInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buildAndRun() async {
    await _buildApp();
    if (_apksController.text.isNotEmpty) {
      await _runApp();
    }
  }

  Future<void> _clearAppData() async {
    if (!mounted || _busy || _packageNameController.text.isEmpty) return;

    setState(() {
      _busy = true;
      _status = 'Clearing app data...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('run --clear-data --device=$_selectedDevice');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'App data cleared';
        _statusType = StatusType.success;
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
        _status = 'Screenshot saved';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _showDeviceInfo() async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Getting device info...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('devices');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = result.output;
        _statusType = StatusType.info;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _loadFromHistory(Map<String, dynamic> entry) {
    setState(() {
      _apksController.text = entry['apk'] ?? '';
      _selectedDevice = entry['device'] ?? '';
      _debugMode = entry['debug'] ?? true;
      _buildVariant = entry['variant'] ?? 'debug';
    });
  }

  void _copyApkPath() {
    Clipboard.setData(ClipboardData(text: _apksController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('APK path copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.contentPadding(context);
    final spacing = Responsive.cardSpacing(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Run / Deploy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _busy ? null : () => _showHistorySheet(),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(spacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Device', style: TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (_loadingDevices)
                                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              else
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 20),
                                  onPressed: _loadDevices,
                                  tooltip: 'Refresh Devices',
                                ),
                            ],
                          ),
                          SizedBox(height: spacing * 0.5),
                          if (_devices.isEmpty)
                            const Text('No devices connected', style: TextStyle(color: Colors.grey))
                          else
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDevice.isNotEmpty ? _selectedDevice : null,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _devices.map((d) => DropdownMenuItem(
                                value: d,
                                child: Row(
                                  children: [
                                    Icon(d.contains('emulator') ? Icons.phone_android : Icons.usb,
                                      size: 16, color: Colors.teal),
                                    const SizedBox(width: 8),
                                    Text(d),
                                  ],
                                ),
                              )).toList(),
                              onChanged: _busy ? null : (v) => setState(() => _selectedDevice = v ?? ''),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(spacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('APK', style: TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.folder_open, size: 20),
                                onPressed: _busy ? null : _selectApkFile,
                                tooltip: 'Browse',
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: _apksController.text.isEmpty ? null : _copyApkPath,
                                tooltip: 'Copy Path',
                              ),
                            ],
                          ),
                          SizedBox(height: spacing * 0.5),
                          TextField(
                            controller: _apksController,
                            decoration: const InputDecoration(
                              labelText: 'APK Path *',
                              hintText: 'build/app/outputs/flutter-apk/app-debug.apk',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_busy,
                          ),
                          SizedBox(height: spacing),
                          TextField(
                            controller: _packageNameController,
                            decoration: const InputDecoration(
                              labelText: 'Package Name',
                              hintText: 'com.example.app',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_busy,
                          ),
                          SizedBox(height: spacing),
                          TextField(
                            controller: _activityController,
                            decoration: const InputDecoration(
                              labelText: 'Activity (optional)',
                              hintText: 'com.example.MainActivity',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_busy,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(spacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Options', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: spacing * 0.5),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'debug', label: Text('Debug'), icon: Icon(Icons.bug_report, size: 16)),
                              ButtonSegment(value: 'release', label: Text('Release'), icon: Icon(Icons.check_circle, size: 16)),
                            ],
                            selected: {_buildVariant},
                            onSelectionChanged: _busy ? null : (v) => setState(() => _buildVariant = v.first),
                          ),
                          SizedBox(height: spacing),
                          SwitchListTile(
                            title: const Text('Uninstall First'),
                            subtitle: const Text('Remove old app before install'),
                            value: _uninstallFirst,
                            onChanged: _busy ? null : (v) => setState(() => _uninstallFirst = v),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          SwitchListTile(
                            title: const Text('Clear Data'),
                            subtitle: const Text('Clear app data before install'),
                            value: _clearData,
                            onChanged: _busy ? null : (v) => setState(() => _clearData = v),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          SwitchListTile(
                            title: const Text('Grant Permissions'),
                            subtitle: const Text('Auto-grant all permissions'),
                            value: _grantPermissions,
                            onChanged: _busy ? null : (v) => setState(() => _grantPermissions = v),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _runApp,
                      icon: _busy
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.play_arrow),
                      label: Text(_busy ? 'Deploying...' : 'Run App'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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
              child: Text('Run History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text('No history'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final entry = _history[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(entry['apk'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${entry['device'] ?? "default"} • ${entry['variant'] ?? "debug"}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context);
                            _loadFromHistory(entry);
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
}
