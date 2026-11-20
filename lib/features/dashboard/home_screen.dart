import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../budgets/budget_screen.dart';
import '../savings/savings_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/providers.dart';
import '../../core/models.dart';
import '../../core/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  int tab = 0;
  final pages = const [
    DashboardPage(),
    BudgetScreen(),
    SavingsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: pages[tab]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Tổng quan',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Ngân sách',
        ),
        NavigationDestination(
          icon: Icon(Icons.savings_outlined),
          label: 'Tiết kiệm',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Báo cáo',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          label: 'Cài đặt',
        ),
      ],
    ),
  );
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider),
        month = ref.watch(selectedMonthProvider),
        budget = data.budget(month),
        spent = data.spent(month),
        total = budget?.total ?? 0;
    String currency(double n) => money(n);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => expenseDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm khoản chi'),
      ),
      body: LayoutBuilder(
        builder: (context, c) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào 👋',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  'Tài chính của bạn',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => monthPicker(context, ref),
                            icon: const Icon(Icons.calendar_month),
                          ),
                          Text('${month.month}/${month.year}'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Card(
                        color: const Color(0xff243b53),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NGÂN SÁCH THÁNG',
                                style: TextStyle(
                                  color: Colors.white70,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currency(total),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: metric(
                                      'Đã chi',
                                      currency(spent),
                                      Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: metric(
                                      'Còn lại',
                                      currency(
                                        (total - spent).clamp(
                                          0,
                                          double.infinity,
                                        ),
                                      ),
                                      const Color(0xff77e0c3),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: LinearProgressIndicator(
                                  value: total == 0
                                      ? 0
                                      : (spent / total).clamp(0, 1),
                                  minHeight: 9,
                                  color: spent >= total
                                      ? Colors.redAccent
                                      : const Color(0xff16a085),
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                total == 0
                                    ? 'Chưa thiết lập ngân sách'
                                    : '${((spent / total).clamp(0, 1) * 100).toStringAsFixed(0)}% đã sử dụng${spent > total ? ' · Đã vượt hạn mức' : ''}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SectionTitle(
                        title: 'Danh mục cần chú ý',
                        action: 'Thiết lập',
                        onTap: () => ref.read(refreshProvider.notifier).state++,
                      ),
                      const SizedBox(height: 8),
                      if (budget == null || budget.limits.isEmpty)
                        const EmptyCard(
                          icon: Icons.pie_chart_outline,
                          title: 'Chưa có ngân sách tháng này',
                          subtitle:
                              'Tạo hạn mức theo danh mục để theo dõi chi tiêu.',
                        )
                      else
                        ...budget.limits.entries
                            .where(
                              (e) =>
                                  e.value > 0 &&
                                  data.spent(month, e.key) / e.value >= .8,
                            )
                            .map(
                              (e) => CategoryTile(
                                category: e.key,
                                limit: e.value,
                                spent: data.spent(month, e.key),
                              ),
                            ),
                      const SizedBox(height: 18),
                      const SectionTitle(title: 'Mục tiêu tiết kiệm'),
                      if (data.goals.isEmpty)
                        const EmptyCard(
                          icon: Icons.savings_outlined,
                          title: 'Chưa có mục tiêu tiết kiệm',
                          subtitle:
                              'Tạo mục tiêu đầu tiên để bắt đầu tích lũy.',
                        )
                      else
                        ...data.goals
                            .take(2)
                            .map(
                              (g) => GoalTile(
                                goal: g,
                                onTap: () => _goalAction(context, ref, g),
                              ),
                            ),
                      const SizedBox(height: 18),
                      SectionTitle(
                        title: 'Giao dịch gần đây',
                        action: 'Thêm khoản chi',
                        onTap: () => expenseDialog(context, ref),
                      ),
                      if (data.monthExpenses(month).isEmpty)
                        const EmptyCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Chưa có giao dịch',
                          subtitle:
                              'Các khoản chi bạn thêm sẽ xuất hiện tại đây.',
                        )
                      else
                        ...data
                            .monthExpenses(month)
                            .reversed
                            .take(5)
                            .map(
                              (e) => ExpenseTile(
                                expense: e,
                                onEdit: () =>
                                    expenseDialog(context, ref, expense: e),
                                onDelete: () async {
                                  await BudgetActions.deleteExpense(e.id);
                                  refresh(ref);
                                },
                              ),
                            ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget metric(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70)),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

Future<void> _goalAction(
  BuildContext context,
  WidgetRef ref,
  SavingsGoal goal,
) async {
  final value = TextEditingController();
  final result = await showDialog<(double, bool)?>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(goal.name),
      content: TextField(
        controller: value,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Số tiền (₫)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Đóng'),
        ),
        TextButton(
          onPressed: () {
            final n = double.tryParse(value.text);
            if (n != null && n > 0) Navigator.pop(ctx, (n, false));
          },
          child: const Text('Rút'),
        ),
        FilledButton(
          onPressed: () {
            final n = double.tryParse(value.text);
            if (n != null && n > 0) Navigator.pop(ctx, (n, true));
          },
          child: const Text('Thêm tiền'),
        ),
      ],
    ),
  );
  if (result == null) return;
  final (amount, add) = result;
  if (!add && amount > goal.saved) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền rút vượt quá số dư mục tiêu')),
      );
    }
    return;
  }
  await BudgetActions.saveGoal(
    goal.id,
    goal.name,
    goal.target,
    add ? goal.saved + amount : goal.saved - amount,
    goal.due,
  );
  refresh(ref);
}

Future<void> monthPicker(BuildContext context, WidgetRef ref) async {
  final current = ref.read(selectedMonthProvider);
  final d = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
    initialDatePickerMode: DatePickerMode.year,
    helpText: 'Chọn tháng (chọn ngày bất kỳ)',
  );
  if (d != null) {
    ref.read(selectedMonthProvider.notifier).state = DateTime(d.year, d.month);
  }
}

Future<void> expenseDialog(
  BuildContext context,
  WidgetRef ref, {
  Expense? expense,
}) async {
  final title = TextEditingController(text: expense?.title),
      amount = TextEditingController(text: expense?.amount.toStringAsFixed(0));
  String cat = expense?.category ?? categories.first;
  final form = GlobalKey<FormState>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(expense == null ? 'Thêm khoản chi' : 'Sửa khoản chi'),
      content: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Tên khoản chi'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nhập tên khoản chi' : null,
            ),
            TextFormField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số tiền (₫)'),
              validator: (v) =>
                  double.tryParse(v ?? '') == null || double.parse(v!) <= 0
                  ? 'Số tiền phải lớn hơn 0'
                  : null,
            ),
            DropdownButtonFormField<String>(
              initialValue: cat,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) cat = v;
              },
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
            if (form.currentState!.validate()) Navigator.pop(ctx, true);
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
  if (ok == true) {
    if (expense == null) {
      await BudgetActions.addExpense(
        title.text.trim(),
        cat,
        double.parse(amount.text),
        ref.read(selectedMonthProvider),
      );
    } else {
      await BudgetActions.updateExpense(
        Expense(
          id: expense.id,
          title: title.text.trim(),
          category: cat,
          amount: double.parse(amount.text),
          date: expense.date,
        ),
      );
    }
    refresh(ref);
  }
}
