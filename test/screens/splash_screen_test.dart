import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/cli_check/presentation/splash_screen.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('SplashScreen', () {
    testWidgets('should render splash screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: const SplashScreen()));
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('should show app title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: const SplashScreen()));
      await tester.pump();
      expect(find.text('Icefish'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('should show Android icon', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: const SplashScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.android), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
