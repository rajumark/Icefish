import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/run_deploy/presentation/run_deploy_content.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('RunDeployContent', () {
    testWidgets('should render Run / Deploy title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RunDeployContent()),
      ));
      await tester.pump();

      expect(find.text('Run / Deploy'), findsWidgets);
    });

    testWidgets('should have history button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RunDeployContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.history), findsWidgets);
    });

    testWidgets('should have more actions button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RunDeployContent()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.more_vert), findsWidgets);
    });

    testWidgets('should show device section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RunDeployContent()),
      ));
      await tester.pump();

      expect(find.text('Device'), findsWidgets);
    });

    testWidgets('should show APK section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RunDeployContent()),
      ));
      await tester.pump();

      expect(find.text('APK'), findsWidgets);
    });

    testWidgets('should show options section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RunDeployContent()),
      ));
      await tester.pump();

      expect(find.text('Options'), findsWidgets);
    });

    testWidgets('should have run app button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RunDeployContent()),
      ));
      await tester.pump();

      expect(find.text('Run App'), findsWidgets);
    });

    testWidgets('should have debug/release toggle', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RunDeployContent()),
      ));
      await tester.pump();

      expect(find.text('Debug'), findsWidgets);
      expect(find.text('Release'), findsWidgets);
    });
  });
}
