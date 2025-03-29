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
  });
}
