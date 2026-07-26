import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/studio/presentation/studio_content.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('StudioContent', () {
    testWidgets('should render Studio title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StudioContent()),
      ));
      await tester.pump();

      expect(find.text('Studio'), findsWidgets);
    });

    testWidgets('should have history button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StudioContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.history), findsWidgets);
    });

    testWidgets('should have quick actions button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StudioContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.more_vert), findsWidgets);
    });

    testWidgets('should show action cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StudioContent()),
      ));
      await tester.pump();

      expect(find.text('Find Declaration'), findsWidgets);
      expect(find.text('Find Usages'), findsWidgets);
      expect(find.text('Open File'), findsWidgets);
      expect(find.text('Analyze File'), findsWidgets);
      expect(find.text('Version Lookup'), findsWidgets);
    });
  });
}
