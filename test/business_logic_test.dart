import 'package:flutter_test/flutter_test.dart';
import 'package:budgetly/core/models.dart';
import 'package:budgetly/core/providers.dart';

void main() {
  test('budget totals expenses by month and category', () {
    final data = AppData(
      [
        Expense(
          id: '1',
          title: 'Lunch',
          category: 'Ăn uống',
          amount: 50000,
          date: DateTime(2026, 11, 4),
        ),
        Expense(
          id: '2',
          title: 'Bus',
          category: 'Đi lại',
          amount: 10000,
          date: DateTime(2026, 11, 5),
        ),
        Expense(
          id: '3',
          title: 'Old',
          category: 'Ăn uống',
          amount: 90000,
          date: DateTime(2026, 10, 5),
        ),
      ],
      [],
      [],
    );
    expect(data.spent(DateTime(2026, 11)), 60000);
    expect(data.spent(DateTime(2026, 11), 'Ăn uống'), 50000);
  });

  test('savings progress is bounded between zero and one', () {
    final goal = SavingsGoal(
      id: 'g',
      name: 'Trip',
      target: 100,
      saved: 150,
      due: DateTime(2027),
    );
    expect(goal.progress, 1);
  });
}
