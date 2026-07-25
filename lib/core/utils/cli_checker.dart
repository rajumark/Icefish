import 'dart:io';

class CliChecker {
  static Future<bool> isAndroidCliInstalled() async {
    try {
      final result = await Process.run('android', ['--version']);
      return result.stdout.toString().trim().isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
