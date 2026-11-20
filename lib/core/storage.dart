import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class AppStorage {
  static late Box expenses;
  static late Box budgets;
  static late Box goals;
  static late Box settings;
  static Future<void> initialize() async {
    await Hive.initFlutter();
    expenses = await Hive.openBox('expenses');
    budgets = await Hive.openBox('budgets');
    goals = await Hive.openBox('goals');
    settings = await Hive.openBox('settings');
  }

  static List<Expense> get allExpenses =>
      expenses.values.map((e) => Expense.fromMap(Map.from(e))).toList();
  static List<Budget> get allBudgets =>
      budgets.values.map((e) => Budget.fromMap(Map.from(e))).toList();
  static List<SavingsGoal> get allGoals =>
      goals.values.map((e) => SavingsGoal.fromMap(Map.from(e))).toList();
}
