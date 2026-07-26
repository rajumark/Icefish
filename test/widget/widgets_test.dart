import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icefish/core/widgets/action_button.dart';
import 'package:icefish/core/widgets/result_card.dart';

void main() {
  group('ActionButton', () {
    testWidgets('should render with label and icon', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ActionButton(
          label: 'Test Button',
          icon: Icons.add,
          onPressed: () {},
        )),
      ));

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ActionButton(
          label: 'Tap Me',
          icon: Icons.touch_app,
          onPressed: () => tapped = true,
        )),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('should show loading when loading is true', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ActionButton(
          label: 'Loading',
          icon: Icons.refresh,
          loading: true,
          onPressed: () {},
        )),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should apply custom color', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ActionButton(
          label: 'Colored',
          icon: Icons.star,
          color: Colors.red,
          onPressed: () {},
        )),
      ));

      expect(find.text('Colored'), findsOneWidget);
    });
  });

  group('ResultCard', () {
    testWidgets('should display title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SizedBox(
          height: 300,
          width: 400,
          child: ResultCard(title: 'My Result', content: 'Some content'),
        )),
      ));

      expect(find.text('My Result'), findsOneWidget);
    });

    testWidgets('should display content', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SizedBox(
          height: 300,
          width: 400,
          child: ResultCard(title: 'Result', content: 'This is the result content'),
        )),
      ));

      expect(find.text('This is the result content'), findsOneWidget);
    });

    testWidgets('should be scrollable for long content', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SizedBox(
          height: 300,
          width: 400,
          child: ResultCard(title: 'Long', content: 'Line\n' * 100),
        )),
      ));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have copy button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SizedBox(
          height: 300,
          width: 400,
          child: ResultCard(title: 'Copy', content: 'text'),
        )),
      ));

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });
  });
}
