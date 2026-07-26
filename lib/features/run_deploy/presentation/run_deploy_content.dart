import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';

class RunDeployContent extends StatefulWidget {
  const RunDeployContent({super.key});

  @override
  State<RunDeployContent> createState() => _RunDeployContentState();
}

class _RunDeployContentState extends State<RunDeployContent> {
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';
  bool _debugMode = true;
  final _apksController = TextEditingController();
  final _activityController = TextEditingController();
  final _deviceController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  void dispose() {
    _apksController.dispose();
    _activityController.dispose();
    _deviceController.dispose();
    _typeController.dispose();
    super.dispose();
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

    setState(() {
      _busy = true;
      _status = 'Deploying app...';
      _statusType = StatusType.loading;
    });

    final args = StringBuffer('run --apks=$apks');
    if (_debugMode) args.write(' --debug');
    if (_deviceController.text.isNotEmpty) args.write(' --device=${_deviceController.text}');
    if (_activityController.text.isNotEmpty) args.write(' --activity=${_activityController.text}');
    if (_typeController.text.isNotEmpty) args.write(' --type=${_typeController.text}');

    final result = await CliService.run(args.toString());
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = result.output.isNotEmpty ? result.output : 'App deployed';
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
              const Icon(Icons.play_circle, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Run / Deploy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                  const Text('Deploy Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apksController,
                    decoration: const InputDecoration(
                      labelText: 'APK Path *',
                      hintText: 'build/app/outputs/flutter-apk/app-debug.apk',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_busy,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deviceController,
                    decoration: const InputDecoration(
                      labelText: 'Device (optional)',
                      hintText: 'emulator-5554',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_busy,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _activityController,
                    decoration: const InputDecoration(
                      labelText: 'Activity (optional)',
                      hintText: 'com.example.MainActivity',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_busy,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type (optional)',
                      hintText: 'ACTIVITY, SERVICE',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_busy,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Debug Mode'),
                    value: _debugMode,
                    onChanged: _busy ? null : (value) => setState(() => _debugMode = value),
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
}
