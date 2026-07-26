import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/docs/presentation/docs_content.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('DocsContent', () {
    testWidgets('should render Documentation title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: DocsContent()),
      ));
      await tester.pump();

      expect(find.text('Documentation'), findsWidgets);
    });

    testWidgets('should have bookmarks button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: DocsContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.bookmark), findsWidgets);
    });

    testWidgets('should have history button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: DocsContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.history), findsWidgets);
    });

    testWidgets('should have quick topics button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: DocsContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.topic), findsWidgets);
    });

    testWidgets('should have search field', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: DocsContent()),
      ));
      await tester.pump();

      expect(find.text('Search Documentation'), findsWidgets);
    });

    testWidgets('should have search button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: DocsContent()),
      ));
      await tester.pump();

      expect(find.text('Search'), findsWidgets);
    });

    testWidgets('should have fetch button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: DocsContent()),
      ));
      await tester.pump();

      expect(find.text('Fetch'), findsWidgets);
    });
  });
}
