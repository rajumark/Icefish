import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/utils/responsive.dart';
import 'package:icefish/core/widgets/status_banner.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

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
  List<String> _filteredTemplates = [];
  final _nameController = TextEditingController();
  final _orgController = TextEditingController();
  final _descController = TextEditingController();
  final _minSdkController = TextEditingController(text: '21');
  final _outputController = TextEditingController();
  final _templateSearchController = TextEditingController();
  String? _selectedTemplate;
  bool _gitInit = true;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _templateSearchController.addListener(_filterTemplates);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _descController.dispose();
    _minSdkController.dispose();
    _outputController.dispose();
    _templateSearchController.dispose();
    super.dispose();
  }

  void _filterTemplates() {
    final query = _templateSearchController.text.toLowerCase();
    setState(() {
      _filteredTemplates = _templates.where((t) =>
        query.isEmpty || t.toLowerCase().contains(query)
      ).toList();
    });
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
        _filteredTemplates = List.from(_templates);
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

    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$').hasMatch(name)) {
      setState(() {
        _status = 'Project name must start with letter, use only letters, numbers, _ or -';
        _statusType = StatusType.error;
      });
      return;
    }

    if (!mounted || _busy) return;

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Create Project',
      message: 'Create project "$name" with ${_selectedTemplate ?? "default"} template?',
      confirmLabel: 'Create',
      confirmColor: Colors.green,
    );

    if (!confirm) return;

    setState(() {
      _busy = true;
      _status = 'Creating project $name...';
      _statusType = StatusType.loading;
    });

    final args = StringBuffer('create --name="$name"');
    if (_orgController.text.isNotEmpty) {
      args.write(' --org=${_orgController.text}');
    }
    if (_descController.text.isNotEmpty) {
      args.write(' --description="${_descController.text}"');
    }
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

    if (result.success && _gitInit) {
      setState(() => _status = 'Initializing git...');
      final projectPath = _outputController.text.isNotEmpty
          ? '${_outputController.text}/$name'
          : name;
      await CliService.run('create --git-init --path=$projectPath');
    }

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

  void _copyProjectPath() {
    final path = _outputController.text.isNotEmpty
        ? '${_outputController.text}/${_nameController.text}'
        : _nameController.text;
    Clipboard.setData(ClipboardData(text: path));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project path copied')),
    );
  }

  void _selectPreset(String template, String minSdk) {
    setState(() {
      _selectedTemplate = template;
      _minSdkController.text = minSdk;
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.contentPadding(context);
    final spacing = Responsive.cardSpacing(context);

    return Padding(
      padding: EdgeInsets.all(padding),
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
                icon: const Icon(Icons.copy),
                onPressed: _nameController.text.isEmpty ? null : _copyProjectPath,
                tooltip: 'Copy Path',
              ),
              IconButton(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                onPressed: _loading || _busy ? null : _loadTemplates,
                tooltip: 'Refresh Templates',
              ),
            ],
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
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                } else {
                  _createProject();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                Step(
                  title: const Text('Project Info'),
                  isActive: _currentStep >= 0,
                  content: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Project Name *',
                          hintText: 'my_app',
                          border: const OutlineInputBorder(),
                          suffixIcon: _nameController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () => _nameController.clear(),
                                )
                              : null,
                        ),
                        enabled: !_busy,
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: spacing),
                      TextField(
                        controller: _orgController,
                        decoration: const InputDecoration(
                          labelText: 'Organization',
                          hintText: 'com.example',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_busy,
                      ),
                      SizedBox(height: spacing),
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'A new Flutter project',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_busy,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Template'),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('Quick: Empty', style: TextStyle(fontSize: 12)),
                            onPressed: () => _selectPreset('empty', '21'),
                          ),
                          ActionChip(
                            label: const Text('Quick: Full', style: TextStyle(fontSize: 12)),
                            onPressed: () => _selectPreset('full', '21'),
                          ),
                          ActionChip(
                            label: const Text('Quick: Minimal', style: TextStyle(fontSize: 12)),
                            onPressed: () => _selectPreset('minimal', '19'),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),
                      TextField(
                        controller: _templateSearchController,
                        decoration: const InputDecoration(
                          hintText: 'Search templates...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        enabled: !_busy,
                      ),
                      SizedBox(height: spacing * 0.5),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _selectedTemplate,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Template',
                            border: OutlineInputBorder(),
                          ),
                          items: _filteredTemplates.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t),
                          )).toList(),
                          onChanged: _busy ? null : (value) {
                            if (value != null) setState(() => _selectedTemplate = value);
                          },
                        ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Options'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    children: [
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
                          SizedBox(width: spacing),
                          Expanded(
                            child: TextField(
                              controller: _outputController,
                              decoration: const InputDecoration(
                                labelText: 'Output Path',
                                hintText: './projects',
                                border: OutlineInputBorder(),
                              ),
                              enabled: !_busy,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),
                      SwitchListTile(
                        title: const Text('Initialize Git'),
                        value: _gitInit,
                        onChanged: _busy ? null : (v) => setState(() => _gitInit = v),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
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
