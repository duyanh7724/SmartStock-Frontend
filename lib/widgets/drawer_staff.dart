// lib/widgets/drawer_staff.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';

class StaffDrawer extends StatelessWidget {
  final Map<String, dynamic> user;
  final Function(String) onSelect;
  const StaffDrawer({
    super.key,
    required this.user,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final fullname = user['fullname']?.toString() ?? 'Nhân viên kho';
    final username = user['username']?.toString() ?? '';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            accountName: Text(
              fullname,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('Tài khoản: $username'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _item(Icons.dashboard, 'Tổng quan', 'dashboard'),
                _item(Icons.inventory_2, 'Sản phẩm trong kho', 'products'),
                _item(Icons.add_box, 'Phiếu nhập', 'import'),
                _item(Icons.outbox, 'Phiếu xuất', 'export'),

                // [MỚI] Thêm mục chat cho nhân viên
                const Divider(),
                _item(
                    Icons.chat_bubble_outline, 'Tin nhắn hỗ trợ', 'chat_list'),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _confirmLogout(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  ListTile _item(IconData icon, String label, String key) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label),
      onTap: () => onSelect(key),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.read<SessionProvider>().clear();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
