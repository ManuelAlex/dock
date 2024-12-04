import 'dart:ui';

import 'package:dock/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
 // Assuming your widget code is in `main.dart`

void main() {
  group('Dock Widget Integration Tests', () {
    testWidgets('Initial render shows all items', (tester) async {
      // Build the Dock widget.
      await tester.pumpWidget(const MaterialApp(home: MyApp()));

      // Verify all items are displayed.
      expect(find.byType(Icon), findsNWidgets(5)); // 5 items in Dock
    });

    // testWidgets('Drag item and verify it is removed temporarily', (tester) async {
    //   await tester.pumpWidget(const MaterialApp(home: MyApp()));

    //   // Find the first draggable icon.
    //   final Finder firstItem = find.byIcon(Icons.person);

    //   // Drag the item.
    //   await tester.drag(firstItem, const Offset(0, -100));
    //   await tester.pumpAndSettle();

    //   // Verify the item is temporarily removed.
    //   expect(find.byIcon(Icons.person), findsNothing);
    // });

//     testWidgets('Drop item back and verify it is reinserted', (tester) async {
//       await tester.pumpWidget(const MaterialApp(home: MyApp()));

//       // Find the first draggable icon.
//       final Finder firstItem = find.byIcon(Icons.person);

//       // Drag and drop it back.
//       await tester.drag(firstItem, const Offset(0, 0));
//       await tester.pumpAndSettle();

//       // Verify the item is back in its original position.
//       expect(find.byIcon(Icons.person), findsOneWidget);
//     });

//     testWidgets('Hover effect increases size', (tester) async {
//       await tester.pumpWidget(const MaterialApp(home: MyApp()));

//       // Find an icon and simulate hover.

//  final Finder messageItem = find.byIcon(Icons.message);
//        final TestGesture gesture =
//       await tester.createGesture(kind: PointerDeviceKind.mouse);
//   await gesture.addPointer(location: Offset.zero);
//   addTearDown(gesture.removePointer);
//   await tester.pump();
//   await gesture.moveTo(tester.getCenter(messageItem));
     
//       final Size originalSize = tester.getSize(messageItem);

     
//       await tester.pump();

//       // Verify size increased due to hover.
//       final Size newSize = tester.getSize(messageItem);
//       expect(newSize.height, greaterThan(originalSize.height));
//       expect(newSize.width, greaterThan(originalSize.width));
//     });

//     testWidgets('Drag item to new position and verify order changes',
//         (tester) async {
//       await tester.pumpWidget(const MaterialApp(home: MyApp()));

//       // Find the draggable items.
//       final Finder item1 = find.byIcon(Icons.person);
//       final Finder item2 = find.byIcon(Icons.message);

//       // Drag the first item to the position of the second item.
//       final item2Position = tester.getCenter(item2);
//       await tester.drag(item1, Offset(item2Position.dx - 10, 0));
//       await tester.pumpAndSettle();

//       // Verify the order has changed.
//       final List<Icon> icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
//       expect(icons[1].icon, Icons.person);
//     });

//     testWidgets('Drag canceled returns item to original position',
//         (tester) async {
//       await tester.pumpWidget(const MaterialApp(home: MyApp()));

//       // Find the first draggable item.
//       final Finder item = find.byIcon(Icons.person);

//       // Drag and cancel it.
//       await tester.drag(item, const Offset(0, -200)); // Simulate an invalid drop
//       await tester.pumpAndSettle();

//       // Verify item is back to its original position.
//       expect(find.byIcon(Icons.person), findsOneWidget);
//     });
  });
}
