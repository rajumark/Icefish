import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/skills/presentation/skills_content.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('SkillsContent', () {
    testWidgets('should render Skills title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SkillsContent()),
      ));
      await tester.pump();

      expect(find.text('Skills'), findsWidgets);
    });

    testWidgets('should have search field', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SkillsContent()),
      ));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should have refresh button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SkillsContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('should have install button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SkillsContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });
}
