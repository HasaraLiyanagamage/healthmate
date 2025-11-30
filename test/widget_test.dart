// This is a basic Flutter widget test for HealthMate app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthmateapp/main.dart';

void main() {
  testWidgets('HealthMate app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthMateApp());

    // Verify that the dashboard screen loads
    expect(find.text('HealthMate Dashboard'), findsOneWidget);
    
    // Verify that today's summary section exists
    expect(find.text("Today's Summary"), findsOneWidget);
    
    // Verify that the floating action button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Add record button navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthMateApp());
    await tester.pumpAndSettle();

    // Tap the floating action button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify that we navigated to the add record screen
    expect(find.text('Add Health Record'), findsOneWidget);
  });

  testWidgets('Dashboard displays health metrics', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthMateApp());
    await tester.pumpAndSettle();

    // Verify that health metric cards are displayed
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Calories Burned'), findsOneWidget);
    expect(find.text('Water Intake'), findsOneWidget);
  });
}
