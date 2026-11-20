import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/widgets.dart';
import '../../core/models.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(dataProvider).goals;
    return Scaffold(
      appBar: AppBar(title: const Text('Mục tiêu tiết kiệm')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => goalDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tạo mục tiêu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (goals.isEmpty)
            const EmptyCard(
              icon: Icons.savings_outlined,
              title: 'Bắt đầu tiết kiệm',
              subtitle: 'Đặt mục tiêu để theo dõi hành trình của bạn.',
            ),
          ...goals.map(
            (g) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    GoalTile(goal: g),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => moneyAction(context, ref, g, false),
                          icon: const Icon(Icons.remove),
                          label: const Text('Rút'),
                        ),
                        TextButton.icon(
                          onPressed: () => moneyAction(context, ref, g, true),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm tiền'),
                        ),
                        IconButton(
                          onPressed: () async {
                            await BudgetActions.deleteGoal(g.id);
                            refresh(ref);
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                        IconButton(
                          onPressed: () => goalEditDialog(context, ref, g),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> goalEditDialog(
  BuildContext context,
  WidgetRef ref,
  SavingsGoal goal,
) async {
  final name = TextEditingController(text: goal.name);
  final target = TextEditingController(text: goal.target.toStringAsFixed(0));
  final due = goal.due;
  final key = GlobalKey<FormState>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sửa mục tiêu'),
      content: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Tên mục tiêu'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nhập tên mục tiêu' : null,
            ),
            TextFormField(
              controller: target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền cần đạt (₫)',
              ),
              validator: (v) =>
                  double.tryParse(v ?? '') == null || double.parse(v!) <= 0
                  ? 'Mục tiêu phải lớn hơn 0'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (key.currentState!.validate()) Navigator.pop(ctx, true);
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
  if (ok == true) {
    await BudgetActions.updateGoal(
      SavingsGoal(
        id: goal.id,
        name: name.text.trim(),
        target: double.parse(target.text),
        saved: goal.saved,
        due: due,
      ),
    );
    refresh(ref);
  }
}

Future<void> goalDialog(BuildContext context, WidgetRef ref) async {
  final name = TextEditingController(),
      target = TextEditingController(),
      saved = TextEditingController(text: '0');
  final key = GlobalKey<FormState>();
  DateTime due = DateTime.now().add(const Duration(days: 180));
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        title: const Text('Mục tiêu mới'),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Tên mục tiêu'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nhập tên' : null,
              ),
              TextFormField(
                controller: target,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền cần đạt (₫)',
                ),
                validator: (v) =>
                    double.tryParse(v ?? '') == null || double.parse(v!) <= 0
                    ? 'Mục tiêu phải lớn hơn 0'
                    : null,
              ),
              TextFormField(
                controller: saved,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Đã tiết kiệm (₫)',
                ),
                validator: (v) =>
                    double.tryParse(v ?? '') == null || double.parse(v!) < 0
                    ? 'Nhập số không âm'
                    : null,
              ),
              TextButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: due,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) set(() => due = d);
                },
                icon: const Icon(Icons.event),
                label: Text(
                  'Hoàn thành dự kiến: ${due.day}/${due.month}/${due.year}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    ),
  );
  if (ok == true) {
    await BudgetActions.saveGoal(
      null,
      name.text.trim(),
      double.parse(target.text),
      double.parse(saved.text),
      due,
    );
    refresh(ref);
  }
}

Future<void> moneyAction(
  BuildContext context,
  WidgetRef ref,
  SavingsGoal goal,
  bool add,
) async {
  final c = TextEditingController();
  final amount = await showDialog<double>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(add ? 'Thêm tiền tiết kiệm' : 'Rút tiền tiết kiệm'),
      content: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Số tiền (₫)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, double.tryParse(c.text)),
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );
  if (amount != null && amount > 0 && (!add && amount > goal.saved)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền rút vượt quá số dư mục tiêu')),
      );
    }
    return;
  }
  if (amount != null && amount > 0) {
    await BudgetActions.saveGoal(
      goal.id,
      goal.name,
      goal.target,
      add ? goal.saved + amount : goal.saved - amount,
      goal.due,
    );
    refresh(ref);
  }
}
