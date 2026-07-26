import 'dart:io';
import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';

class ScreenContent extends StatefulWidget {
  const ScreenContent({super.key});

  @override
  State<ScreenContent> createState() => _ScreenContentState();
}

class _ScreenContentState extends State<ScreenContent> {
  bool _busy = false;
  String _status = '';
  StatusType _statusType = StatusType.info;
  String? _screenshotPath;
  String? _resolvedElement;

  Future<void> _captureScreen() async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Capturing screenshot...';
      _statusType = StatusType.loading;
      _screenshotPath = null;
    });

    final result = await CliService.run('screen capture');
    if (!mounted) return;

    if (result.success && result.output.contains('Screenshot written to')) {
      final path = result.output.split('to ').last.trim();
      setState(() {
        _screenshotPath = path;
        _status = 'Screenshot saved';
        _statusType = StatusType.success;
        _busy = false;
      });
    } else {
      setState(() {
        _status = result.error.isNotEmpty ? result.error : result.output;
        _statusType = StatusType.error;
        _busy = false;
      });
    }
  }

  Future<void> _resolveScreen() async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Resolving UI elements...';
      _statusType = StatusType.loading;
      _resolvedElement = null;
    });

    final result = await CliService.run('screen resolve');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _resolvedElement = result.output;
        _status = 'UI elements resolved';
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
              const Icon(Icons.photo_camera, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Screen Capture', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                onPressed: _busy ? null : _captureScreen,
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera_alt),
                label: Text(_busy ? 'Capturing...' : 'Capture Screenshot'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _busy ? null : _resolveScreen,
                icon: const Icon(Icons.touch_app),
                label: const Text('Resolve UI'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_resolvedElement != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resolved UI Elements', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                        child: Text(_resolvedElement!, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_screenshotPath != null)
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Screenshot', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Image.file(
                          File(_screenshotPath!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('Failed to load image'));
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_screenshotPath!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
