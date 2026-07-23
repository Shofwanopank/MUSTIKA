import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rotimustika/main.dart';

void main() {
  testWidgets('App renders login screen when not logged in', (WidgetTester tester) async {
    // Build app dengan isLoggedIn = false (belum login)
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that login screen muncul
    expect(find.text('Roti Mustika'), findsOneWidget);
    expect(find.text('BAKERY ADMIN PORTAL'), findsOneWidget);
    expect(find.text('Login to Dashboard'), findsOneWidget);
  });

  testWidgets('App goes directly to dashboard when logged in', (WidgetTester tester) async {
    // Build app dengan isLoggedIn = true (sudah login)
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    // Verify langsung masuk dashboard, bukan login screen
    expect(find.text('Login to Dashboard'), findsNothing);
  });
}