import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/utils/responsive.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

class SkillsContent extends StatefulWidget {
  const SkillsContent({super.key});

  @override
  State<SkillsContent> createState() => _SkillsContentState();
}

class _SkillsContentState extends State<SkillsContent> {
  List<String> _skills = [];
  List<String> _filteredSkills = [];
  Set<String> _selected = {};
  bool _loading = true;
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSkills();
    _searchController.addListener(_filterSkills);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSkills() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSkills = _skills.where((s) {
        final matchesSearch = query.isEmpty || s.toLowerCase().contains(query);
        return matchesSearch;
      }).toList();
    });
  }

  Future<void> _loadSkills() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _status = '';
    });

    final result = await CliService.run('skills list');
    if (!mounted) return;

    setState(() {
      if (result.success) {
        _skills = result.output.split('\n').where((e) => e.trim().isNotEmpty).toList();
        _filterSkills();
        _status = '';
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
      _loading = false;
    });
  }

  Future<void> _findSkills(String query) async {
    if (query.isEmpty) {
      _loadSkills();
      return;
    }
    if (!mounted) return;

    setState(() {
      _loading = true;
      _status = 'Searching...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('skills find $query');
    if (!mounted) return;

    setState(() {
      if (result.success) {
        _skills = result.output.split('\n').where((e) => e.trim().isNotEmpty).toList();
        _filterSkills();
        _status = '';
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
      _loading = false;
    });
  }

  Future<void> _installSkill(String name) async {
    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Installing $name...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('skills add $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name installed';
        _statusType = StatusType.success;
        _loadSkills();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _removeSkill(String name) async {
    if (!mounted || _busy) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Remove Skill',
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

    final result = await CliService.run('skills remove $name');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$name removed';
        _statusType = StatusType.success;
        _loadSkills();
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _installSelected() async {
    if (!mounted || _busy || _selected.isEmpty) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Install Skills',
      message: 'Install ${_selected.length} skills?',
      confirmLabel: 'Install All',
      confirmColor: Colors.green,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Installing ${_selected.length} skills...';
      _statusType = StatusType.loading;
    });

    int installed = 0;
    for (final skill in _selected) {
      final result = await CliService.run('skills add $skill');
      if (result.success) installed++;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _selected.clear();
      _status = '$installed skills installed';
      _statusType = StatusType.success;
      _loadSkills();
    });
  }

  Future<void> _removeSelected() async {
    if (!mounted || _busy || _selected.isEmpty) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Remove Skills',
      message: 'Remove ${_selected.length} skills?',
      confirmLabel: 'Remove All',
      confirmColor: Colors.red,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Removing ${_selected.length} skills...';
      _statusType = StatusType.loading;
    });

    int removed = 0;
    for (final skill in _selected) {
      final result = await CliService.run('skills remove $skill');
      if (result.success) removed++;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _selected.clear();
      _status = '$removed skills removed';
      _statusType = StatusType.success;
      _loadSkills();
    });
  }

  void _showSkillInfo(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.extension),
              title: const Text('Name'),
              subtitle: Text(name),
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
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
                const SnackBar(content: Text('Skill name copied')),
              );
            },
            child: const Text('Copy Name'),
          ),
        ],
      ),
    );
  }

  void _showInstallDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Install Skill'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter skill name',
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
                _installSkill(name);
              }
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selected.length == _filteredSkills.length) {
        _selected.clear();
      } else {
        _selected = Set.from(_filteredSkills);
      }
    });
  }

  void _toggleSelection(String skill) {
    setState(() {
      if (_selected.contains(skill)) {
        _selected.remove(skill);
      } else {
        _selected.add(skill);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final skillCount = _skills.length;
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
              const Icon(Icons.extension, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Skills', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(width: spacing),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$skillCount skills', style: const TextStyle(color: Colors.teal, fontSize: 12)),
              ),
              const Spacer(),
              if (selectedCount > 0) ...[
                TextButton.icon(
                  onPressed: _busy ? null : _installSelected,
                  icon: const Icon(Icons.download, size: 16),
                  label: Text('Install ($selectedCount)'),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _removeSelected,
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: Text('Remove ($selectedCount)', style: const TextStyle(color: Colors.red)),
                ),
              ],
              IconButton(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                onPressed: _loading || _busy ? null : _loadSkills,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _busy ? null : _showInstallDialog,
                tooltip: 'Install Skill',
              ),
            ],
          ),
          SizedBox(height: spacing),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search skills...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSkills();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: _findSkills,
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
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_filteredSkills.isEmpty)
            const Expanded(child: Center(child: Text('No skills found')))
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
                          value: _selected.length == _filteredSkills.length && _filteredSkills.isNotEmpty,
                          onChanged: (_) => _toggleSelectAll(),
                        ),
                        Text('${_selected.length}/${_filteredSkills.length} selected'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredSkills.length,
                      itemBuilder: (context, index) {
                        final skill = _filteredSkills[index];
                        final isSelected = _selected.contains(skill);
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleSelection(skill),
                            ),
                            title: Text(skill),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline, size: 20),
                                  onPressed: () => _showSkillInfo(skill),
                                  tooltip: 'Info',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.green, size: 20),
                                  onPressed: _busy ? null : () => _installSkill(skill),
                                  tooltip: 'Install',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: _busy ? null : () => _removeSkill(skill),
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
