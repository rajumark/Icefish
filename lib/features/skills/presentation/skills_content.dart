import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

class SkillsContent extends StatefulWidget {
  const SkillsContent({super.key});

  @override
  State<SkillsContent> createState() => _SkillsContentState();
}

class _SkillsContentState extends State<SkillsContent> {
  List<String> _skills = [];
  bool _loading = true;
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadSkills();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.extension, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Skills', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                onPressed: _loading || _busy ? null : _loadSkills,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search skills...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _loadSkills();
                },
              ),
            ),
            onSubmitted: _findSkills,
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
          else if (_skills.isEmpty)
            const Expanded(child: Center(child: Text('No skills found')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _skills.length,
                itemBuilder: (context, index) {
                  final skill = _skills[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.extension),
                      title: Text(skill),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.green),
                            onPressed: _busy ? null : () => _installSkill(skill),
                            tooltip: 'Install',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
    );
  }
}
