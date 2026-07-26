import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/core/utils/responsive.dart';
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
  List<String> _screenshotHistory = [];
  String _lastTapCoords = '';
  String _orientation = 'portrait';
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    _loadScreenshotHistory();
  }

  Future<void> _loadScreenshotHistory() async {
    final result = await CliService.run('screen history');
    if (!mounted || !result.success) return;
    setState(() {
      _screenshotHistory = result.output.split('\n').where((l) => l.trim().isNotEmpty).toList();
    });
  }

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
      _loadScreenshotHistory();
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

  Future<void> _startRecording() async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _status = 'Recording started...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('screen record --start');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'Recording in progress. Tap Stop to finish.';
        _statusType = StatusType.info;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _status = 'Stopping recording...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('screen record --stop');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'Recording saved';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _rotateScreen(String direction) async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _status = 'Rotating screen $direction...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('screen rotate $direction');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'Screen rotated to $direction';
        _statusType = StatusType.success;
        _orientation = direction;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _setBrightness(double value) async {
    if (!mounted) return;
    setState(() => _brightness = value);
    await CliService.run('screen brightness $value');
  }

  Future<void> _tapScreen(int x, int y) async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _status = 'Tapping ($x, $y)...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('screen tap $x $y');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _lastTapCoords = '($x, $y)';
        _status = 'Tapped at ($x, $y)';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _showTapDialog() {
    final xController = TextEditingController(text: '540');
    final yController = TextEditingController(text: '960');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tap Screen'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: xController,
                decoration: const InputDecoration(labelText: 'X', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: yController,
                decoration: const InputDecoration(labelText: 'Y', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final x = int.tryParse(xController.text) ?? 0;
              final y = int.tryParse(yController.text) ?? 0;
              Navigator.pop(context);
              _tapScreen(x, y);
            },
            child: const Text('Tap'),
          ),
        ],
      ),
    );
  }

  void _showSwipeDialog() {
    final x1Controller = TextEditingController(text: '540');
    final y1Controller = TextEditingController(text: '1500');
    final x2Controller = TextEditingController(text: '540');
    final y2Controller = TextEditingController(text: '500');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Swipe Screen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: x1Controller, decoration: const InputDecoration(labelText: 'Start X', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: y1Controller, decoration: const InputDecoration(labelText: 'Start Y', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: x2Controller, decoration: const InputDecoration(labelText: 'End X', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: y2Controller, decoration: const InputDecoration(labelText: 'End Y', border: OutlineInputBorder()))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final x1 = int.tryParse(x1Controller.text) ?? 0;
              final y1 = int.tryParse(y1Controller.text) ?? 0;
              final x2 = int.tryParse(x2Controller.text) ?? 0;
              final y2 = int.tryParse(y2Controller.text) ?? 0;
              Navigator.pop(context);
              _swipeScreen(x1, y1, x2, y2);
            },
            child: const Text('Swipe'),
          ),
        ],
      ),
    );
  }

  Future<void> _swipeScreen(int x1, int y1, int x2, int y2) async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _status = 'Swiping...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('screen swipe $x1 $y1 $x2 $y2');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'Swiped from ($x1,$y1) to ($x2,$y2)';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _showInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input Text'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter text to type',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                _inputText(text);
              }
            },
            child: const Text('Input'),
          ),
        ],
      ),
    );
  }

  Future<void> _inputText(String text) async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _status = 'Inputting text...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('screen input "$text"');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = 'Text input sent';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  Future<void> _pressKey(String key) async {
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _status = 'Pressing $key...';
      _statusType = StatusType.loading;
    });

    final result = await CliService.run('screen key $key');
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _status = '$key pressed';
        _statusType = StatusType.success;
      } else {
        _status = result.error;
        _statusType = StatusType.error;
      }
    });
  }

  void _copyScreenshotPath() {
    if (_screenshotPath != null) {
      Clipboard.setData(ClipboardData(text: _screenshotPath!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screenshot path copied')),
      );
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Screen Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.screen_rotation, color: Colors.blue),
              title: const Text('Rotate Screen'),
              onTap: () {
                Navigator.pop(context);
                _showRotationSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6, color: Colors.orange),
              title: const Text('Brightness'),
              onTap: () {
                Navigator.pop(context);
                _showBrightnessSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.keyboard, color: Colors.teal),
              title: const Text('Input Text'),
              onTap: () {
                Navigator.pop(context);
                _showInputDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.touch_app, color: Colors.purple),
              title: const Text('Tap Coordinates'),
              onTap: () {
                Navigator.pop(context);
                _showTapDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.swipe, color: Colors.green),
              title: const Text('Swipe'),
              onTap: () {
                Navigator.pop(context);
                _showSwipeDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRotationSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Rotate Screen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.screen_lock_portrait),
              title: const Text('Portrait'),
              trailing: _orientation == 'portrait' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () { Navigator.pop(context); _rotateScreen('portrait'); },
            ),
            ListTile(
              leading: const Icon(Icons.screen_lock_landscape),
              title: const Text('Landscape'),
              trailing: _orientation == 'landscape' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () { Navigator.pop(context); _rotateScreen('landscape'); },
            ),
            ListTile(
              leading: const Icon(Icons.screen_lock_landscape),
              title: const Text('Reverse Landscape'),
              onTap: () { Navigator.pop(context); _rotateScreen('reverse_landscape'); },
            ),
            ListTile(
              leading: const Icon(Icons.screen_lock_portrait),
              title: const Text('Reverse Portrait'),
              onTap: () { Navigator.pop(context); _rotateScreen('reverse_portrait'); },
            ),
            ListTile(
              leading: const Icon(Icons.screen_rotation),
              title: const Text('Auto Rotate'),
              onTap: () { Navigator.pop(context); _rotateScreen('auto'); },
            ),
          ],
        ),
      ),
    );
  }

  void _showBrightnessSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Brightness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.brightness_low),
                  Expanded(
                    child: Slider(
                      value: _brightness,
                      onChanged: _setBrightness,
                    ),
                  ),
                  const Icon(Icons.brightness_high),
                ],
              ),
              Text('${(_brightness * 100).round()}%'),
            ],
          ),
        ),
      ),
    );
  }

  void _showKeyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Press Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter key code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                ActionChip(label: const Text('Home', style: TextStyle(fontSize: 11)), onPressed: () => controller.text = 'home'),
                ActionChip(label: const Text('Back', style: TextStyle(fontSize: 11)), onPressed: () => controller.text = 'back'),
                ActionChip(label: const Text('Recent', style: TextStyle(fontSize: 11)), onPressed: () => controller.text = 'recent'),
                ActionChip(label: const Text('Power', style: TextStyle(fontSize: 11)), onPressed: () => controller.text = 'power'),
                ActionChip(label: const Text('Volume Up', style: TextStyle(fontSize: 11)), onPressed: () => controller.text = 'volume_up'),
                ActionChip(label: const Text('Volume Down', style: TextStyle(fontSize: 11)), onPressed: () => controller.text = 'volume_down'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                Navigator.pop(context);
                _pressKey(key);
              }
            },
            child: const Text('Press'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.contentPadding(context);
    final spacing = Responsive.cardSpacing(context);
    final isCompact = Responsive.isCompact(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera, size: 32, color: Colors.teal),
              const SizedBox(width: 12),
              const Text('Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _busy ? null : _showScreenshotHistory,
                tooltip: 'Screenshot History',
              ),
              IconButton(
                icon: const Icon(Icons.keyboard),
                onPressed: _busy ? null : _showKeyDialog,
                tooltip: 'Press Key',
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _busy ? null : _showQuickActions,
                tooltip: 'More Actions',
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
          Wrap(
            spacing: spacing * 0.5,
            runSpacing: spacing * 0.5,
            children: [
              ElevatedButton.icon(
                onPressed: _busy ? null : _captureScreen,
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera_alt),
                label: Text(_busy ? 'Working...' : 'Screenshot'),
              ),
              ElevatedButton.icon(
                onPressed: _busy ? null : _resolveScreen,
                icon: const Icon(Icons.touch_app),
                label: const Text('Resolve UI'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _startRecording,
                icon: const Icon(Icons.videocam),
                label: const Text('Record'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ],
          ),
          SizedBox(height: spacing),
          if (_lastTapCoords.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: spacing * 0.5),
              child: Text('Last tap: $_lastTapCoords', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          Expanded(
            child: isCompact
                ? _buildCompactLayout(context, spacing)
                : _buildExpandedLayout(context, spacing),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context, double spacing) {
    if (_resolvedElement != null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('UI Elements', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _resolvedElement!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UI hierarchy copied')),
                      );
                    },
                    tooltip: 'Copy',
                  ),
                ],
              ),
              SizedBox(height: spacing * 0.5),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_resolvedElement!, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_screenshotPath != null) {
      return _buildScreenshotCard(context, spacing);
    }
    return const SizedBox.shrink();
  }

  Widget _buildExpandedLayout(BuildContext context, double spacing) {
    return Row(
      children: [
        if (_resolvedElement != null)
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('UI Elements', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _resolvedElement!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('UI hierarchy copied')),
                            );
                          },
                          tooltip: 'Copy',
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 0.5),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(_resolvedElement!, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_resolvedElement != null && _screenshotPath != null) SizedBox(width: spacing),
        if (_screenshotPath != null)
          Expanded(child: _buildScreenshotCard(context, spacing)),
      ],
    );
  }

  Widget _buildScreenshotCard(BuildContext context, double spacing) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Screenshot', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: _copyScreenshotPath,
                  tooltip: 'Copy Path',
                ),
              ],
            ),
            SizedBox(height: spacing * 0.5),
            Expanded(
              child: Image.file(
                File(_screenshotPath!),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Failed to load image'));
                },
              ),
            ),
            SizedBox(height: spacing * 0.5),
            Text(_screenshotPath!, style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _showScreenshotHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Screenshot History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _screenshotHistory.isEmpty
                  ? const Center(child: Text('No screenshots yet'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _screenshotHistory.length,
                      itemBuilder: (context, index) {
                        final path = _screenshotHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.image),
                          title: Text(path.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(path, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10)),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: path));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Path copied')),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => _screenshotPath = path);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
