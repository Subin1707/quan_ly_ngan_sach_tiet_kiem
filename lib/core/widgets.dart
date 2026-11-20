import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'providers.dart';

String money(double n) => NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
).format(n);
void refresh(WidgetRef ref) => ref.read(refreshProvider.notifier).state++;

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
    ],
  );
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff16a085), size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.limit,
    required this.spent,
  });
  final String category;
  final double limit, spent;
  @override
  Widget build(BuildContext context) {
    final p = limit == 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${money(spent)} / ${money(limit)}',
                  style: TextStyle(
                    color: p >= 1
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: p,
                minHeight: 7,
                color: p >= 1
                    ? Colors.red
                    : p >= .8
                    ? Colors.orange
                    : const Color(0xff16a085),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                p >= 1
                    ? 'Vượt ${money(spent - limit)}'
                    : 'Còn ${money(limit - spent)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    this.onDelete,
    this.onEdit,
  });
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xffe5f4f0),
        child: const Icon(Icons.receipt_long, color: Color(0xff16a085)),
      ),
      title: Text(expense.title),
      subtitle: Text(
        '${expense.category} · ${DateFormat('dd/MM').format(expense.date)}',
      ),
      onTap: onEdit,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '− ${money(expense.amount)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    ),
  );
}

class GoalTile extends StatelessWidget {
  const GoalTile({super.key, required this.goal, this.onTap});
  final SavingsGoal goal;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Icon(Icons.savings_outlined)),
      title: Text(goal.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${money(goal.saved)} / ${money(goal.target)} · ${DateFormat('dd/MM/yyyy').format(goal.due)}',
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: goal.progress,
            color: const Color(0xff16a085),
          ),
        ],
      ),
      trailing: Text('${(goal.progress * 100).toStringAsFixed(0)}%'),
    ),
  );
}
