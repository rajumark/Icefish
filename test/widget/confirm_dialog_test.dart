import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/widgets/confirm_dialog.dart';

void main() {
  group('ConfirmDialog', () {
    testWidgets('should show dialog with title and message', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ConfirmDialog.show(
              context: context,
              title: 'Confirm',
              message: 'Are you sure?',
            ),
            child: const Text('Show'),
          ),
        )),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Confirm'), findsWidgets);
      expect(find.text('Are you sure?'), findsWidgets);
    });

    testWidgets('should return true when confirm tapped', (WidgetTester tester) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ConfirmDialog.show(
                context: context,
                title: 'Confirm',
                message: 'Proceed?',
                confirmLabel: 'Yes',
              );
            },
            child: const Text('Show'),
          ),
        )),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();

      await tester.tap(find.text('Yes'));
      await tester.pump();

      expect(result, isTrue);
    });

    testWidgets('should return false when cancel tapped', (WidgetTester tester) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ConfirmDialog.show(
                context: context,
                title: 'Confirm',
                message: 'Proceed?',
              );
            },
            child: const Text('Show'),
          ),
        )),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(result, isFalse);
    });

    testWidgets('should use custom confirm color', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ConfirmDialog.show(
              context: context,
              title: 'Delete',
              message: 'Delete item?',
              confirmColor: Colors.red,
            ),
            child: const Text('Show'),
          ),
        )),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Delete'), findsWidgets);
    });
  });
}
