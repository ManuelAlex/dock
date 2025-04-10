// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:dock/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Count dock items', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify the length of dock icon.
    final Finder dockFinder = find.byType(Dock<IconData>);
    final int iconsLength =
        tester
            .widgetList<Icon>(
              find.descendant(of: dockFinder, matching: find.byType(Icon)),
            )
            .length;
    expect(5, iconsLength);

    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Count dock items', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify the length of dock icon.
    final dockFinder = find.byType(Dock<IconData>);
    final iconsLength =
        tester
            .widgetList<Icon>(
              find.descendant(of: dockFinder, matching: find.byType(Icon)),
            )
            .length;
    expect(5, iconsLength);
  });

  testWidgets('Hovering over an item applies vertical offset', (tester) async {
    await tester.pumpWidget(const MyApp());

    final Finder iconFinder = find.byIcon(Icons.call);
    final double originalY = tester.getTopLeft(iconFinder).dy;

    // Simulate mouse hover
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(iconFinder));
    await tester.pumpAndSettle();

    final double hoveredY = tester.getTopLeft(iconFinder).dy;

    expect(
      hoveredY,
      lessThan(originalY),
      reason: 'Item should float up on hover',
    );
  });

  testWidgets('Dragging one item onto another reorders them', (tester) async {
    await tester.pumpWidget(const MyApp());

    final Finder personIcon = find.byIcon(Icons.person);
    final Finder messageIcon = find.byIcon(Icons.message);

    // Start dragging person icon
    final gesture = await tester.startGesture(tester.getCenter(personIcon));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(messageIcon));
    await gesture.up();
    await tester.pumpAndSettle();

    // Get new positions
    final Offset personPositionAfter = tester.getTopLeft(
      find.byIcon(Icons.person),
    );
    final Offset messagePositionAfter = tester.getTopLeft(
      find.byIcon(Icons.message),
    );

    // Person icon should now be where message icon was
    expect(personPositionAfter.dx, greaterThan(messagePositionAfter.dx));
  });
}
