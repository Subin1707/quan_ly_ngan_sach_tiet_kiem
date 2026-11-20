import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets.dart';
import '../../core/storage.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider),
        data = ref.watch(dataProvider),
        b = data.budget(month);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách tháng'),
        actions: [
          IconButton(
            onPressed: () => editBudget(context, ref),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => editBudget(context, ref),
        icon: const Icon(Icons.tune),
        label: Text(b == null ? 'Tạo ngân sách' : 'Điều chỉnh'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            '${month.month}/${month.year}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (b == null)
            const EmptyCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Chưa có ngân sách tháng này',
              subtitle: 'Phân bổ hạn mức cho từng danh mục.',
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TỔNG HẠN MỨC'),
                    Text(
                      money(b.total),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Đã chi ${money(data.spent(month))} · Còn ${money((b.total - data.spent(month)).clamp(0, double.infinity))}',
                    ),
                  ],
                ),
              ),
            ),
            ...categories.map(
              (c) => CategoryTile(
                category: c,
                limit: b.limits[c] ?? 0,
                spent: data.spent(month, c),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> editBudget(BuildContext context, WidgetRef ref) async {
  final m = ref.read(selectedMonthProvider),
      old = ref.read(dataProvider).budget(m);
  final ctrls = {
    for (final c in categories)
      c: TextEditingController(text: old?.limits[c]?.toStringAsFixed(0) ?? ''),
  };
  final key = GlobalKey<FormState>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Ngân sách ${m.month}/${m.year}'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: categories
                  .map(
                    (c) => TextFormField(
                      controller: ctrls[c],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: c,
                        suffixText: '₫',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = double.tryParse(v);
                        return n == null || n < 0 ? 'Nhập số không âm' : null;
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      actions: [
        if (old != null)
          TextButton(
            onPressed: () async {
              await AppStorage.budgets.delete(old.id);
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Xóa ngân sách'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
  if (ok == true) {
    final limits = {
      for (final e in ctrls.entries)
        if ((double.tryParse(e.value.text) ?? 0) > 0)
          e.key: double.parse(e.value.text),
    };
    if (limits.isNotEmpty) await BudgetActions.saveBudget(m, limits);
    refresh(ref);
  }
}
