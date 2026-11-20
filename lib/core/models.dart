import 'package:hive/hive.dart';

const categories = [
  'Ăn uống',
  'Mua sắm',
  'Đi lại',
  'Học tập',
  'Giải trí',
  'Hóa đơn',
  'Sức khỏe',
  'Khác',
];

class Expense extends HiveObject {
  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });
  String id, title, category;
  double amount;
  DateTime date;
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
  };
  static Expense fromMap(Map map) => Expense(
    id: map['id'],
    title: map['title'],
    category: map['category'],
    amount: (map['amount'] as num).toDouble(),
    date: DateTime.parse(map['date']),
  );
}

class Budget extends HiveObject {
  Budget({
    required this.id,
    required this.year,
    required this.month,
    required this.limits,
  });
  String id;
  int year, month;
  Map<String, double> limits;
  double get total => limits.values.fold(0, (a, b) => a + b);
  Map<String, dynamic> toMap() => {
    'id': id,
    'year': year,
    'month': month,
    'limits': limits,
  };
  static Budget fromMap(Map map) => Budget(
    id: map['id'],
    year: map['year'],
    month: map['month'],
    limits: Map<String, double>.from(
      (map['limits'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())),
    ),
  );
}

class SavingsGoal extends HiveObject {
  SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    required this.saved,
    required this.due,
  });
  String id, name;
  double target, saved;
  DateTime due;
  double get progress =>
      target <= 0 ? 0 : (saved / target).clamp(0, 1).toDouble();
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'target': target,
    'saved': saved,
    'due': due.toIso8601String(),
  };
  static SavingsGoal fromMap(Map map) => SavingsGoal(
    id: map['id'],
    name: map['name'],
    target: (map['target'] as num).toDouble(),
    saved: (map['saved'] as num).toDouble(),
    due: DateTime.parse(map['due']),
  );
}
