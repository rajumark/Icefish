import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

class SdkContent extends StatefulWidget {
  const SdkContent({super.key});

  @override
  State<SdkContent> createState() => _SdkContentState();
}

class _SdkContentState extends State<SdkContent> with SingleTickerProviderStateMixin {
  List<String> _packages = [];
  List<String> _filteredPackages = [];
  Set<String> _selected = {};
  bool _loading = true;
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _sortBy = 'name';
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => _applyFilters());
    _loadPackages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
        _applyFilters();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
      _loading = false;
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPackages = _packages.where((p) {
        final matchesSearch = query.isEmpty || p.toLowerCase().contains(query);
        return matchesSearch;
      }).toList();

      _filteredPackages.sort((a, b) {
        final cmp = a.toLowerCase().compareTo(b.toLowerCase());
        return _sortAsc ? cmp : -cmp;
      });
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

  Future<void> _updateAllPackages() async {
    if (!mounted || _busy) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Update All Packages',
      message: 'Update all ${_filteredPackages.length} packages?',
      confirmLabel: 'Update All',
      confirmColor: Colors.blue,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Updating all packages...';
      _statusType = StatusType.loading;
    });

    int updated = 0;
    for (final pkg in _filteredPackages) {
      final result = await CliService.run('sdk update $pkg');
      if (result.success) updated++;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = '$updated packages updated';
      _statusType = StatusType.success;
      _loadPackages();
    });
  }

  void _showInstallDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Install Package'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. platforms/android-34',
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
                  label: const Text('platforms;android-34', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'platforms;android-34',
                ),
                ActionChip(
                  label: const Text('build-tools;34.0.0', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'build-tools;34.0.0',
                ),
                ActionChip(
                  label: const Text('platform-tools', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'platform-tools',
                ),
                ActionChip(
                  label: const Text('emulator', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'emulator',
                ),
              ],
            ),
          ],
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

  void _showPackageInfo(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Package'),
              subtitle: Text(name),
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Type'),
              subtitle: Text(name.contains(';') ? name.split(';').first : 'SDK Platform'),
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Status'),
              subtitle: const Text('Installed'),
              dense: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: name));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Package name copied')),
              );
            },
            child: const Text('Copy Name'),
          ),
        ],
      ),
    );
  }

  void _exportPackageList() {
    final json = const JsonEncoder.withIndent('  ').convert(_packages);
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package list copied to clipboard')),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selected.length == _filteredPackages.length) {
        _selected.clear();
      } else {
        _selected = Set.from(_filteredPackages);
      }
    });
  }

  void _toggleSelection(String pkg) {
    setState(() {
      if (_selected.contains(pkg)) {
        _selected.remove(pkg);
      } else {
        _selected.add(pkg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final installedCount = _packages.length;
    final selectedCount = _selected.length;

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
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$installedCount packages', style: const TextStyle(color: Colors.teal, fontSize: 12)),
              ),
              const Spacer(),
              if (selectedCount > 0)
                TextButton.icon(
                  onPressed: _busy ? null : _updateAllPackages,
                  icon: const Icon(Icons.update, size: 16),
                  label: Text('Update Selected ($selectedCount)'),
                ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _exportPackageList,
                tooltip: 'Export List',
              ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search packages...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: Badge(
                  label: Text(_sortAsc ? 'A' : 'Z', style: const TextStyle(fontSize: 10)),
                  child: const Icon(Icons.sort),
                ),
                onSelected: (value) {
                  setState(() {
                    if (_sortBy == value) {
                      _sortAsc = !_sortAsc;
                    } else {
                      _sortBy = value;
                      _sortAsc = true;
                    }
                  });
                  _applyFilters();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          else if (_filteredPackages.isEmpty)
            const Expanded(child: Center(child: Text('No packages found')))
          else
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _selected.length == _filteredPackages.length,
                          onChanged: (_) => _toggleSelectAll(),
                        ),
                        Text('${_selected.length}/${_filteredPackages.length} selected'),
                        const Spacer(),
                        if (_selected.isNotEmpty) ...[
                          TextButton.icon(
                            onPressed: _busy ? null : _updateAllPackages,
                            icon: const Icon(Icons.update, size: 14),
                            label: const Text('Update', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton.icon(
                            onPressed: _busy ? null : () {
                              for (final pkg in _selected) {
                                _removePackage(pkg);
                              }
                            },
                            icon: const Icon(Icons.delete, size: 14, color: Colors.red),
                            label: const Text('Remove', style: TextStyle(fontSize: 12, color: Colors.red)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredPackages.length,
                      itemBuilder: (context, index) {
                        final package = _filteredPackages[index];
                        final isSelected = _selected.contains(package);
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleSelection(package),
                            ),
                            title: Text(package, maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text(package.contains(';') ? package.split(';').first : 'SDK Platform',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline, size: 20),
                                  onPressed: () => _showPackageInfo(package),
                                  tooltip: 'Info',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.update, color: Colors.blue, size: 20),
                                  onPressed: _busy ? null : () => _updatePackage(package),
                                  tooltip: 'Update',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
            ),
        ],
      ),
    );
  }
}
