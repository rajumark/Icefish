import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/utils/responsive.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

class SdkContent extends StatefulWidget {
  const SdkContent({super.key});

  @override
  State<SdkContent> createState() => _SdkContentState();
}

class _SdkContentState extends State<SdkContent> {
  List<_PackageRow> _packages = [];
  List<_PackageRow> _filteredPackages = [];
  Set<String> _selected = {};
  bool _loading = true;
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';
  final _searchController = TextEditingController();
  String _sortBy = 'name';
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  @override
  void dispose() {
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
        ).map((line) => _PackageRow.fromRaw(line.trim())).toList();
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
        final matchesSearch = query.isEmpty ||
            p.name.toLowerCase().contains(query) ||
            p.type.toLowerCase().contains(query);
        return matchesSearch;
      }).toList();

      _filteredPackages.sort((a, b) {
        int cmp;
        switch (_sortBy) {
          case 'type':
            cmp = a.type.compareTo(b.type);
            break;
          case 'status':
            cmp = a.statusLabel.compareTo(b.statusLabel);
            break;
          default:
            cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
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
    final toUpdate = _selected.isEmpty ? _filteredPackages : _filteredPackages.where((p) => _selected.contains(p.name)).toList();
    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Update Packages',
      message: 'Update ${toUpdate.length} packages?',
      confirmLabel: 'Update All',
      confirmColor: Colors.blue,
    );
    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Updating ${toUpdate.length} packages...';
      _statusType = StatusType.loading;
    });

    int updated = 0;
    for (final pkg in toUpdate) {
      final result = await CliService.run('sdk update ${pkg.name}');
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
                hintText: 'e.g. platforms;android-34',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _installPackage(v.trim());
                }
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                ActionChip(label: const Text('platforms;android-34', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'platforms;android-34'),
                ActionChip(label: const Text('build-tools;34.0.0', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'build-tools;34.0.0'),
                ActionChip(label: const Text('platform-tools', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'platform-tools'),
                ActionChip(label: const Text('emulator', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'emulator'),
                ActionChip(label: const Text('sources;android-34', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'sources;android-34'),
                ActionChip(label: const Text('system-images', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'system-images'),
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

  void _exportPackageList() {
    final json = const JsonEncoder.withIndent('  ').convert(
      _packages.map((p) => {'name': p.name, 'type': p.type, 'status': p.statusLabel}).toList(),
    );
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package list copied to clipboard')),
    );
  }

  void _copyPackageName(String name) {
    Clipboard.setData(ClipboardData(text: name));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package name copied')),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selected.length == _filteredPackages.length) {
        _selected.clear();
      } else {
        _selected = Set.from(_filteredPackages.map((p) => p.name));
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

  void _cycleSort(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAsc = !_sortAsc;
      } else {
        _sortBy = column;
        _sortAsc = true;
      }
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final installedCount = _packages.length;
    final selectedCount = _selected.length;
    final padding = Responsive.contentPadding(context);
    final spacing = Responsive.cardSpacing(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('SDK Manager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(width: spacing),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$installedCount packages', style: const TextStyle(color: Colors.teal, fontSize: 12)),
              ),
              if (selectedCount > 0) ...[
                SizedBox(width: spacing * 0.5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$selectedCount selected', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ],
              const Spacer(),
              if (selectedCount > 0)
                TextButton.icon(
                  onPressed: _busy ? null : _updateAllPackages,
                  icon: const Icon(Icons.update, size: 16),
                  label: const Text('Update Selected'),
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
          SizedBox(height: spacing),
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
            ],
          ),
          SizedBox(height: spacing),
          if (_status.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: spacing),
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
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              value: _selected.length == _filteredPackages.length && _filteredPackages.isNotEmpty,
                              onChanged: (_) => _toggleSelectAll(),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: InkWell(
                              onTap: () => _cycleSort('name'),
                              child: Row(
                                children: [
                                  const Text('Package', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  if (_sortBy == 'name')
                                    Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () => _cycleSort('type'),
                              child: Row(
                                children: [
                                  const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  if (_sortBy == 'type')
                                    Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () => _cycleSort('status'),
                              child: Row(
                                children: [
                                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  if (_sortBy == 'status')
                                    Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 140, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredPackages.length,
                        itemBuilder: (context, index) {
                          final pkg = _filteredPackages[index];
                          final isSelected = _selected.contains(pkg.name);
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : null,
                              border: Border(
                                bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleSelection(pkg.name),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: InkWell(
                                    onTap: () => _copyPackageName(pkg.name),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Text(pkg.name, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: pkg.typeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(pkg.type, style: TextStyle(fontSize: 11, color: pkg.typeColor),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(pkg.statusIcon, size: 14, color: pkg.statusColor),
                                        const SizedBox(width: 4),
                                        Text(pkg.statusLabel, style: TextStyle(fontSize: 11, color: pkg.statusColor)),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          pkg.isInstalled ? Icons.update : Icons.download,
                                          color: pkg.isInstalled ? Colors.blue : Colors.green,
                                          size: 18,
                                        ),
                                        onPressed: _busy ? null : () => pkg.isInstalled ? _updatePackage(pkg.name) : _installPackage(pkg.name),
                                        tooltip: pkg.isInstalled ? 'Update' : 'Install',
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 18),
                                        onPressed: () => _copyPackageName(pkg.name),
                                        tooltip: 'Copy',
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      if (pkg.isInstalled)
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                          onPressed: _busy ? null : () => _removePackage(pkg.name),
                                          tooltip: 'Remove',
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

class _PackageRow {
  final String raw;
  final String name;
  final String type;
  final bool isInstalled;

  _PackageRow._(this.raw, this.name, this.type, this.isInstalled);

  factory _PackageRow.fromRaw(String raw) {
    final lower = raw.toLowerCase();
    final installed = lower.contains('installed') || lower.contains('(installed)');
    String type = 'SDK Platform';
    if (lower.contains('build-tools')) {
      type = 'Build Tools';
    } else if (lower.contains('platform-tools')) {
      type = 'Platform Tools';
    } else if (lower.contains('emulator')) {
      type = 'Emulator';
    } else if (lower.contains('sources')) {
      type = 'Sources';
    } else if (lower.contains('system-images')) {
      type = 'System Image';
    } else if (lower.contains('cmdline-tools')) {
      type = 'CLI Tools';
    } else if (lower.contains('extras')) {
      type = 'Extras';
    } else if (lower.contains('patcher')) {
      type = 'Patcher';
    } else if (lower.contains('ndk')) {
      type = 'NDK';
    } else if (lower.contains('cmake')) {
      type = 'CMake';
    } else if (lower.contains('lldb')) {
      type = 'LLDB';
    }
    return _PackageRow._(raw, raw, type, installed);
  }

  String get statusLabel => isInstalled ? 'Installed' : 'Available';

  IconData get statusIcon => isInstalled ? Icons.check_circle : Icons.cloud_download;

  Color get statusColor => isInstalled ? Colors.green : Colors.grey;

  Color get typeColor {
    switch (type) {
      case 'Build Tools': return Colors.blue;
      case 'Platform Tools': return Colors.teal;
      case 'Emulator': return Colors.orange;
      case 'Sources': return Colors.purple;
      case 'System Image': return Colors.red;
      case 'CLI Tools': return Colors.indigo;
      case 'NDK': return Colors.brown;
      case 'CMake': return Colors.cyan;
      case 'LLDB': return Colors.deepOrange;
      default: return Colors.teal;
    }
  }
}
