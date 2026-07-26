import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/widgets/status_banner.dart';

void main() {
  group('StatusBanner', () {
    testWidgets('should display info message', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatusBanner(
          message: 'Test message',
          type: StatusType.info,
        )),
      ));

      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('should display success message', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatusBanner(
          message: 'Success!',
          type: StatusType.success,
        )),
      ));

      expect(find.text('Success!'), findsOneWidget);
    });

    testWidgets('should display error message', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatusBanner(
          message: 'Error occurred',
          type: StatusType.error,
        )),
      ));

      expect(find.text('Error occurred'), findsOneWidget);
    });

    testWidgets('should display loading message', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatusBanner(
          message: 'Loading...',
          type: StatusType.loading,
        )),
      ));

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should have dismiss callback', (WidgetTester tester) async {
      bool dismissed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatusBanner(
          message: 'Dismissable',
          type: StatusType.info,
          onDismiss: () => dismissed = true,
        )),
      ));

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });
  });
}
