import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/create_project/presentation/create_project_content.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('CreateProjectContent', () {
    testWidgets('should render Create Project title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CreateProjectContent()),
      ));
      await tester.pump();

      expect(find.text('Create Project'), findsWidgets);
    });

    testWidgets('should have refresh button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CreateProjectContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('should have copy path button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CreateProjectContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.copy), findsWidgets);
    });

    testWidgets('should show stepper', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CreateProjectContent()),
      ));
      await tester.pump();

      expect(find.byType(Stepper), findsOneWidget);
    });

    testWidgets('should have project name field', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CreateProjectContent()),
      ));
      await tester.pump();

      expect(find.text('Project Name *'), findsWidgets);
    });

    testWidgets('should have organization field', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CreateProjectContent()),
      ));
      await tester.pump();

      expect(find.text('Organization'), findsWidgets);
    });

    testWidgets('should have description field', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CreateProjectContent()),
      ));
      await tester.pump();

      expect(find.text('Description'), findsWidgets);
    });
  });
}
