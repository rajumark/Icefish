import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Package Type Detection', () {
    String detectType(String name) {
      final lower = name.toLowerCase();
      if (lower.contains('build-tools')) return 'Build Tools';
      if (lower.contains('platform-tools')) return 'Platform Tools';
      if (lower.contains('emulator')) return 'Emulator';
      if (lower.contains('sources')) return 'Sources';
      if (lower.contains('system-images')) return 'System Image';
      if (lower.contains('cmdline-tools')) return 'CLI Tools';
      if (lower.contains('extras')) return 'Extras';
      if (lower.contains('patcher')) return 'Patcher';
      if (lower.contains('ndk')) return 'NDK';
      if (lower.contains('cmake')) return 'CMake';
      if (lower.contains('lldb')) return 'LLDB';
      return 'SDK Platform';
    }

    test('should detect Build Tools', () {
      expect(detectType('build-tools;34.0.0'), 'Build Tools');
    });

    test('should detect Platform Tools', () {
      expect(detectType('platform-tools'), 'Platform Tools');
    });

    test('should detect Emulator', () {
      expect(detectType('emulator'), 'Emulator');
    });

    test('should detect Sources', () {
      expect(detectType('sources;android-34'), 'Sources');
    });

    test('should detect System Image', () {
      expect(detectType('system-images;android-34;google_apis;x86_64'), 'System Image');
    });

    test('should detect CLI Tools', () {
      expect(detectType('cmdline-tools;latest'), 'CLI Tools');
    });

    test('should detect NDK', () {
      expect(detectType('ndk;26.1.10909125'), 'NDK');
    });

    test('should detect CMake', () {
      expect(detectType('cmake;3.22.1'), 'CMake');
    });

    test('should detect LLDB', () {
      expect(detectType('lldb;17.0.4598428'), 'LLDB');
    });

    test('should default to SDK Platform', () {
      expect(detectType('platforms;android-34'), 'SDK Platform');
    });

    test('should handle empty string', () {
      expect(detectType(''), 'SDK Platform');
    });
  });

  group('Installed Status Detection', () {
    bool isInstalled(String raw) {
      final lower = raw.toLowerCase();
      return lower.contains('installed') || lower.contains('(installed)');
    }

    test('should detect installed package', () {
      expect(isInstalled('platforms;android-34 (installed)'), isTrue);
    });

    test('should detect available package', () {
      expect(isInstalled('platforms;android-35'), isFalse);
    });

    test('should handle case insensitive', () {
      expect(isInstalled('Package (INSTALLED)'), isTrue);
    });
  });

  group('Project Name Validation', () {
    bool isValidName(String name) {
      if (name.isEmpty) return false;
      if (!RegExp(r'^[a-zA-Z]').hasMatch(name)) return false;
      return RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$').hasMatch(name);
    }

    test('should accept valid names', () {
      expect(isValidName('my_app'), isTrue);
      expect(isValidName('MyApp'), isTrue);
      expect(isValidName('app-1'), isTrue);
      expect(isValidName('test_app_2'), isTrue);
    });

    test('should reject empty name', () {
      expect(isValidName(''), isFalse);
    });

    test('should reject name starting with number', () {
      expect(isValidName('1app'), isFalse);
    });

    test('should reject name with spaces', () {
      expect(isValidName('my app'), isFalse);
    });

    test('should reject name with special chars', () {
      expect(isValidName('my@app'), isFalse);
    });
  });
}
