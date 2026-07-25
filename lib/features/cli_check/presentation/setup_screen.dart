import 'dart:io';
import 'package:flutter/material.dart';
import 'package:icefish/features/cli_check/presentation/home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _installing = false;
  String _status = '';

  Future<void> _installCli() async {
    setState(() {
      _installing = true;
      _status = 'Downloading installer...';
    });

    try {
      final download = await Process.run(
        '/bin/bash',
        ['-c', 'curl -fsSL https://dl.google.com/android/cli/latest/darwin_arm64/install.sh -o /tmp/android_cli_install.sh'],
      );

      if (download.exitCode != 0) {
        setState(() {
          _status = 'Download failed: ${download.stderr}';
          _installing = false;
        });
        return;
      }

      setState(() => _status = 'Installing...');

      final install = await Process.run(
        '/bin/bash',
        ['-c', 'chmod +x /tmp/android_cli_install.sh && /tmp/android_cli_install.sh'],
      );

      if (install.exitCode == 0) {
        setState(() => _status = 'Installed! Restarting...');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _status = 'Failed: ${install.stderr}';
          _installing = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _installing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Required'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('Android CLI Not Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Please install Android CLI to continue'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _installing ? null : _installCli,
              icon: _installing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
              label: Text(_installing ? 'Installing...' : 'Install Android CLI'),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_status, style: TextStyle(color: _status.contains('Failed') || _status.contains('Error') ? Colors.red : Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
