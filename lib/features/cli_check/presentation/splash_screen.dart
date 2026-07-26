import 'package:flutter/material.dart';
import 'package:icefish/core/utils/cli_checker.dart';
import 'package:icefish/features/cli_check/presentation/home_screen.dart';
import 'package:icefish/features/cli_check/presentation/setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkCli();
  }

  Future<void> _checkCli() async {
    await Future.delayed(const Duration(seconds: 2));
    final installed = await CliChecker.isAndroidCliInstalled();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => installed ? const HomeScreen() : const SetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.android, size: 80, color: Colors.teal),
            SizedBox(height: 24),
            Text('Icefish', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
