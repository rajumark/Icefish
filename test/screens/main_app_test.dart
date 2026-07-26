import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/services/cli_service.dart';
import 'package:icefish/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setupFakeCli(defaultResponse: CliResult.ok(''));
  });

  tearDown(() {
    resetCliService();
  });

  group('Main App', () {
    testWidgets('should render MaterialApp', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MyApp());
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('should have theme configuration', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MyApp());
      await tester.pump();
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
      expect(app.darkTheme, isNotNull);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
