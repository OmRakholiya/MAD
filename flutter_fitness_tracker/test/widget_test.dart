import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fitness_tracker/main.dart';

void main() {
  testWidgets('App loads and displays FitTracker text', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(FitnessTrackerApp());

    // Verify that the app loads and shows FitTracker text
    expect(find.text('FitTracker'), findsOneWidget);
  });

  testWidgets('Splash screen shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(FitnessTrackerApp());

    // Verify that loading indicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
