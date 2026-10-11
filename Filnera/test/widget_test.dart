// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:filnera/app.dart';
import 'package:filnera/features/settings/presentation/pages/settings_page.dart';

void main() {
  testWidgets('app renders the storefront shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ManaraApp());
    await tester.pumpAndSettle();

    expect(find.text('Manara Store'), findsOneWidget);
  });

  testWidgets('settings page exposes the global theme selector', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });
}
