import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/features/cli_check/presentation/home_screen.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('HomeScreen Navigation', () {
    testWidgets('should render NavigationRail', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(child: const HomeScreen()));
      await tester.pump();

      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('should have 10 navigation destinations', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(child: const HomeScreen()));
      await tester.pump();

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.children.length, 10);
    });

    testWidgets('should show all screen labels in rail', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(child: const HomeScreen()));
      await tester.pump();

      for (final label in ['Home', 'Create', 'Emulator', 'Run', 'SDK', 'Screen', 'Layout', 'Skills', 'Docs', 'Studio']) {
        expect(find.text(label), findsWidgets);
      }
    });

    testWidgets('should render IndexedStack', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(child: const HomeScreen()));
      await tester.pump();

      expect(find.byType(IndexedStack), findsOneWidget);
    });
  });
}
