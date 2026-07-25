import 'package:flutter/material.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Required'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
            SizedBox(height: 24),
            Text('Android CLI Not Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Please install Android CLI to continue'),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Run:\ncurl -fsSL https://dl.google.com/android/cli/latest/darwin_arm64/install.sh | bash',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
