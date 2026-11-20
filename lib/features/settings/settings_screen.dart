import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/storage.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Giao diện tối'),
              subtitle: const Text('Áp dụng chế độ sáng hoặc tối'),
              value: dark,
              onChanged: (v) async {
                await AppStorage.settings.put('dark', v);
                ref.read(darkModeProvider.notifier).state = v;
              },
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Lưu trữ trên thiết bị'),
              subtitle: Text(
                'Dữ liệu được lưu cục bộ bằng Hive. Không cần tài khoản hoặc kết nối mạng.',
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Budgetly'),
              subtitle: Text('Personal Budget Planner · Phiên bản 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
