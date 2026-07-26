import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _loading = true;
  String _cliVersion = '';
  String _sdkPath = '';
  String _launcherVersion = '';
  StatusType _statusType = StatusType.info;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _status = '';
    });

    final versionResult = await CliService.run('--version');
    if (!mounted) return;

    final infoResult = await CliService.run('info');
    if (!mounted) return;

    if (versionResult.success && infoResult.success) {
      final lines = infoResult.output.split('\n');
      var sdk = '';
      var launcher = '';
      for (final line in lines) {
        if (line.startsWith('sdk:')) sdk = line.replaceFirst('sdk:', '').trim();
        if (line.startsWith('launcher_version:')) launcher = line.replaceFirst('launcher_version:', '').trim();
      }
      setState(() {
        _cliVersion = versionResult.output;
        _sdkPath = sdk;
        _launcherVersion = launcher;
        _loading = false;
      });
    } else {
      setState(() {
        _status = versionResult.error.isNotEmpty ? versionResult.error : infoResult.error;
        _statusType = StatusType.error;
        _loading = false;
      });
    }
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
              const Icon(Icons.home, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Home', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                onPressed: _loading ? null : _loadInfo,
                tooltip: 'Refresh',
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
          else
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Android CLI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _InfoRow(icon: Icons.info_outline, label: 'Version', value: _cliVersion),
                          const SizedBox(height: 12),
                          _InfoRow(icon: Icons.folder_outlined, label: 'SDK Path', value: _sdkPath),
                          const SizedBox(height: 12),
                          _InfoRow(icon: Icons.rocket_launch, label: 'Launcher', value: _launcherVersion),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value.isEmpty ? 'N/A' : value, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
