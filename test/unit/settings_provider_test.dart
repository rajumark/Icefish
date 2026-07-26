import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icefish/core/providers/settings_provider.dart';

void main() {
  group('SettingsProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should default to system theme', () {
      final provider = SettingsProvider();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('should set theme to dark', () async {
      final provider = SettingsProvider();
      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should set theme to light', () async {
      final provider = SettingsProvider();
      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('should notify listeners on theme change', () async {
      final provider = SettingsProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      await provider.setThemeMode(ThemeMode.dark);
      expect(notified, isTrue);
    });

    test('should persist theme choice', () async {
      final provider = SettingsProvider();
      await provider.setThemeMode(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt('theme_mode');
      expect(savedIndex, ThemeMode.dark.index);
    });

    test('should load persisted theme', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 2}); // dark
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.themeMode, ThemeMode.dark);
    });
  });
}
