import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

class SdkContent extends StatefulWidget {
  const SdkContent({super.key});

  @override
  State<SdkContent> createState() => _SdkContentState();
}

class _SdkContentState extends State<SdkContent> {
  List<String> _packages = [];
  bool _loading = true;
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _status = '';
    });

    final result = await CliService.run('sdk list');
    if (!mounted) return;

    setState(() {
      if (result.success) {
        _packages = result.output.split('\n').where((e) =>
          e.trim().isNotEmpty &&
          !e.startsWith('Installed') &&
          !e.startsWith('Available') &&
          !e.startsWith('-')
        ).toList();
        _status = '';
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
      _loading = false;
    });
  }

  Future<void> _installPackage(String name) async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Installing $name...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('sdk install $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name installed';
        _statusType = StatusType.success;
        _loadPackages();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _updatePackage(String name) async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Updating $name...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('sdk update $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name updated';
        _statusType = StatusType.success;
        _loadPackages();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _removePackage(String name) async {
    if (!mounted || _busy) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Remove Package',
      message: 'Remove $name?',
      confirmLabel: 'Remove',
      confirmColor: Colors.red,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Removing $name...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('sdk remove $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name removed';
        _statusType = StatusType.success;
        _loadPackages();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _showInstallDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Install Package'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. platforms/android-34',
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
                _installPackage(name);
              }
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
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
              const Icon(Icons.inventory_2, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('SDK Manager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                onPressed: _loading || _busy ? null : _loadPackages,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _busy ? null : _showInstallDialog,
                tooltip: 'Install Package',
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
          else if (_packages.isEmpty)
            const Expanded(child: Center(child: Text('No packages found')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final package = _packages[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(package, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.update, color: Colors.blue),
                            onPressed: _busy ? null : () => _updatePackage(package),
                            tooltip: 'Update',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _busy ? null : () => _removePackage(package),
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
