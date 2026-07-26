import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/screen/presentation/screen_content.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('ScreenContent', () {
    testWidgets('should render Screen title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ScreenContent()),
      ));
      await tester.pump();

      expect(find.text('Screen'), findsWidgets);
    });

    testWidgets('should have history button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ScreenContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.history), findsWidgets);
    });

    testWidgets('should have keyboard button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ScreenContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.keyboard), findsWidgets);
    });

    testWidgets('should have more actions button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ScreenContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.more_vert), findsWidgets);
    });

    testWidgets('should have screenshot button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ScreenContent()),
      ));
      await tester.pump();

      expect(find.text('Screenshot'), findsWidgets);
    });

    testWidgets('should have resolve UI button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ScreenContent()),
      ));
      await tester.pump();

      expect(find.text('Resolve UI'), findsWidgets);
    });

    testWidgets('should have record button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ScreenContent()),
      ));
      await tester.pump();

      expect(find.text('Record'), findsWidgets);
    });

    testWidgets('should have stop button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ScreenContent()),
      ));
      await tester.pump();

      expect(find.text('Stop'), findsWidgets);
    });
  });
}
