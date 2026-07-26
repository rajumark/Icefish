import 'package:flutter/material.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/widgets/status_banner.dart';

class CreateProjectContent extends StatefulWidget {
  const CreateProjectContent({super.key});

  @override
  State<CreateProjectContent> createState() => _CreateProjectContentState();
}

class _CreateProjectContentState extends State<CreateProjectContent> {
  bool _loading = true;
  bool _busy = false;
  StatusType _statusType = StatusType.info;
  String _status = '';
  List<String> _templates = [];
  final _nameController = TextEditingController();
  final _minSdkController = TextEditingController(text: '21');
  final _outputController = TextEditingController();
  String? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minSdkController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _status = '';
    });

    final result = await CliService.run('create --list');
    if (!mounted) return;

    setState(() {
      if (result.success) {
        final lines = result.output.split('\n');
        _templates = [];
        for (final line in lines) {
          if (line.trim().isNotEmpty && !line.startsWith('Template') && !line.startsWith('-')) {
            final name = line.split(RegExp(r'\s{2,}')).first.trim();
            if (name.isNotEmpty) _templates.add(name);
          }
        }
        if (_templates.isNotEmpty) {
          _selectedTemplate = _templates.first;
        }
        _status = '';
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
      _loading = false;
    });
  }

  Future<void> _createProject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _status = 'Please enter a project name';
        _statusType = StatusType.error;
      });
      return;
    }

    if (!mounted || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Creating project $name...';
      _statusType = StatusType.loading;
    });

    final args = StringBuffer('create --name="$name"');
    if (_minSdkController.text.isNotEmpty) {
      args.write(' --minSdk=${_minSdkController.text}');
    }
    if (_outputController.text.isNotEmpty) {
      args.write(' --output=${_outputController.text}');
    }
    if (_selectedTemplate != null) {
      args.write(' $_selectedTemplate');
    }

    final result = await CliService.run(args.toString());
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'Project "$name" created successfully!';
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
              const Icon(Icons.create_new_folder, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Create Project', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                onPressed: _loading || _busy ? null : _loadTemplates,
                tooltip: 'Refresh Templates',
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                      hintText: 'My App',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_busy,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minSdkController,
                          decoration: const InputDecoration(
                            labelText: 'Min SDK',
                            hintText: '21',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_busy,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _outputController,
                          decoration: const InputDecoration(
                            labelText: 'Output Path (optional)',
                            hintText: './my-app',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_busy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTemplate,
                      decoration: const InputDecoration(
                        labelText: 'Template',
                        border: OutlineInputBorder(),
                      ),
                      items: _templates.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t),
                      )).toList(),
                      onChanged: _busy ? null : (value) {
                        if (value != null) setState(() => _selectedTemplate = value);
                      },
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _createProject,
                      icon: _busy
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.create),
                      label: Text(_busy ? 'Creating...' : 'Create Project'),
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
