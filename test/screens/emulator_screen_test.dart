import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/emulator/presentation/emulator_content.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('EmulatorContent', () {
    testWidgets('should render Emulator title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: EmulatorContent()),
      ));
      await tester.pump();

      expect(find.text('Emulator'), findsWidgets);
    });

    testWidgets('should have refresh button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: EmulatorContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('should have create emulator button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: EmulatorContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('should show empty state after loading', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: EmulatorContent()),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('No emulators found. Tap + to create one.'), findsOneWidget);
    });
  });
}
