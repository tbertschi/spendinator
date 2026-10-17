import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendinator/main.dart';
import 'package:spendinator/screens/budget_screen.dart';

void main() {
  testWidgets('Spendinator app loads successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SpendinatorApp());
    await tester.pumpAndSettle();

    expect(find.byType(BudgetScreen), findsOneWidget);
  });
}
