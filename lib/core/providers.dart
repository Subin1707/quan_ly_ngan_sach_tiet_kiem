import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'storage.dart';

final refreshProvider = StateProvider<int>((ref) => 0);
final darkModeProvider = StateProvider<bool>(
  (ref) => AppStorage.settings.get('dark', defaultValue: false) as bool,
);
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final dataProvider = Provider<AppData>((ref) {
  ref.watch(refreshProvider);
  return AppData(
    AppStorage.allExpenses,
    AppStorage.allBudgets,
    AppStorage.allGoals,
  );
});

class AppData {
  AppData(this.expenses, this.budgets, this.goals);
  final List<Expense> expenses;
  final List<Budget> budgets;
  final List<SavingsGoal> goals;
  Budget? budget(DateTime month) {
    for (final b in budgets) {
      if (b.month == month.month && b.year == month.year) return b;
    }
    return null;
  }

  List<Expense> monthExpenses(DateTime month) => expenses
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();
  double spent(DateTime month, [String? category]) => monthExpenses(month)
      .where((e) => category == null || e.category == category)
      .fold(0, (s, e) => s + e.amount);
}

class BudgetActions {
  static Future<void> saveBudget(
    DateTime month,
    Map<String, double> limits,
  ) async {
    final found = AppStorage.budgets.values
        .map((e) => Budget.fromMap(Map.from(e)))
        .where((b) => b.month == month.month && b.year == month.year);
    final old = found.isEmpty ? null : found.first;
    final b = Budget(
      id: old?.id ?? const Uuid().v4(),
      year: month.year,
      month: month.month,
      limits: limits,
    );
    await AppStorage.budgets.put(b.id, b.toMap());
  }

  static Future<void> addExpense(
    String title,
    String category,
    double amount,
    DateTime date,
  ) async {
    final e = Expense(
      id: const Uuid().v4(),
      title: title,
      category: category,
      amount: amount,
      date: date,
    );
    await AppStorage.expenses.put(e.id, e.toMap());
  }

  static Future<void> deleteExpense(String id) async {
    await AppStorage.expenses.delete(id);
  }

  static Future<void> updateExpense(Expense expense) async {
    await AppStorage.expenses.put(expense.id, expense.toMap());
  }

  static Future<void> saveGoal(
    String? id,
    String name,
    double target,
    double saved,
    DateTime due,
  ) async {
    final g = SavingsGoal(
      id: id ?? const Uuid().v4(),
      name: name,
      target: target,
      saved: saved,
      due: due,
    );
    await AppStorage.goals.put(g.id, g.toMap());
  }

  static Future<void> updateGoal(SavingsGoal goal) async {
    await AppStorage.goals.put(goal.id, goal.toMap());
  }

  static Future<void> deleteGoal(String id) async {
    await AppStorage.goals.delete(id);
  }
}
