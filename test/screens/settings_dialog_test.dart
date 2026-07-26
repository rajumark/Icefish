import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:icefish/core/providers/settings_provider.dart';
import 'package:icefish/features/cli_check/presentation/settings_dialog.dart';

void main() {
  group('SettingsDialog', () {
    Widget wrapWithProvider(Widget child) {
      return ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('should show settings dialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProvider(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
          child: const Text('Open'),
        ),
      )));

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('should show theme label', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProvider(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
          child: const Text('Open'),
        ),
      )));

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.text('Theme'), findsWidgets);
    });

    testWidgets('should show theme options', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProvider(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
          child: const Text('Open'),
        ),
      )));

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.text('System'), findsWidgets);
      expect(find.text('Light'), findsWidgets);
      expect(find.text('Dark'), findsWidgets);
    });

    testWidgets('should have close button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProvider(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
          child: const Text('Open'),
        ),
      )));

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.text('Close'), findsWidgets);
    });
  });
}
