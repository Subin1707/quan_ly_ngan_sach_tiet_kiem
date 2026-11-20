import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/widgets.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const colors = [
    Color(0xff16a085),
    Color(0xfff39c12),
    Color(0xff2980b9),
    Color(0xff8e44ad),
    Color(0xffe74c3c),
    Color(0xff2c3e50),
    Color(0xffd35400),
    Color(0xff7f8c8d),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final month = ref.watch(selectedMonthProvider);
    final budget = data.budget(month);
    final spent = data.spent(month);
    final values = categories.map((c) => data.spent(month, c)).toList();
    final expenseTotal = values.fold<double>(0, (a, b) => a + b);
    final history = List.generate(
      6,
      (i) => DateTime(month.year, month.month - 5 + i),
    );
    final maxValue = [
      ...data.budgets.map((b) => b.total),
      ...history.map(data.spent),
    ].fold<double>(1000000, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Tổng kết ${month.month}/${month.year}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: summary('Tổng ngân sách', money(budget?.total ?? 0)),
              ),
              const SizedBox(width: 10),
              Expanded(child: summary('Tổng đã chi', money(spent))),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiêu theo danh mục',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (expenseTotal == 0)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: Text('Chưa có dữ liệu chi tiêu')),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 45,
                          sections: List.generate(
                            categories.length,
                            (i) => PieChartSectionData(
                              value: values[i],
                              title: values[i] == 0
                                  ? ''
                                  : '${(values[i] / expenseTotal * 100).round()}%',
                              color: colors[i],
                              radius: 55,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ...List.generate(
                    categories.length,
                    (i) => legend(categories[i], colors[i], values[i]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sử dụng ngân sách',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (budget == null || budget.limits.isEmpty)
                    const Text('Thiết lập ngân sách để xem tiến độ.')
                  else
                    ...budget.limits.entries.map((e) {
                      final amount = data.spent(month, e.key);
                      final progress = e.value == 0
                          ? 0.0
                          : (amount / e.value).clamp(0.0, 1.0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(e.key)),
                                Text('${money(amount)} / ${money(e.value)}'),
                              ],
                            ),
                            const SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: progress,
                              color: progress >= 1
                                  ? Colors.red
                                  : progress >= .8
                                  ? Colors.orange
                                  : const Color(0xff16a085),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'So sánh ngân sách 6 tháng',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 190,
                    child: BarChart(
                      BarChartData(
                        maxY: maxValue * 1.15,
                        barGroups: List.generate(history.length, (i) {
                          final date = history[i];
                          final limit = data.budget(date)?.total ?? 0;
                          final amount = data.spent(date);
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: limit,
                                width: 10,
                                color: const Color(0xff243b53),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              BarChartRodData(
                                toY: amount,
                                width: 10,
                                color: const Color(0xff16a085),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= history.length) {
                                  return const SizedBox.shrink();
                                }
                                final date = history[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    '${date.month}/${date.year % 100}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.square, size: 12, color: Color(0xff243b53)),
                      Text(' Ngân sách    '),
                      Icon(Icons.square, size: 12, color: Color(0xff16a085)),
                      Text(' Đã chi'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget summary(String title, String value) => Card(
  child: Padding(
    padding: const EdgeInsets.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    ),
  ),
);

Widget legend(String title, Color color, double value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    children: [
      Icon(Icons.circle, size: 10, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(title)),
      Text(money(value)),
    ],
  ),
);
