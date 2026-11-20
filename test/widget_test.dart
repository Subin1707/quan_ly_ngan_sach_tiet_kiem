// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:budgetly/app.dart';
import 'package:budgetly/core/storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Budgetly dashboard renders', (WidgetTester tester) async {
    Hive.init('budgetly_test');
    await AppStorage.initialize();
    await tester.pumpWidget(const ProviderScope(child: BudgetlyApp()));
    expect(find.text('Tài chính của bạn'), findsOneWidget);
    expect(find.text('Ngân sách tháng'), findsNothing);
  });
}
