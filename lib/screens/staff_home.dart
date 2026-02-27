// lib/screens/staff_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../widgets/drawer_staff.dart';

import 'admin/admin_dashboard.dart';
// [MỚI] Import trang danh sách chat (dùng chung với Admin)
import 'admin/admin_chat_list.dart';

import 'staff/staff_products.dart';
import 'staff/staff_import.dart';
import 'staff/staff_export.dart';
import 'scan_add_product.dart';

class StaffHome extends StatefulWidget {
  const StaffHome({super.key});

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  String _page = 'dashboard';

  // Key để sau này gọi reload() trong StaffProducts khi quét xong sản phẩm
  final GlobalKey<StaffProductsState> _productsKey =
      GlobalKey<StaffProductsState>();

  @override
  Widget build(BuildContext context) {
    // 1. Thử lấy user từ Arguments (lúc vừa đăng nhập xong)
    final argUser =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // 2. Nếu không có, lấy từ SessionProvider (lúc reload app)
    final sessionUser = context.watch<SessionProvider>().currentUser;

    // 3. Ưu tiên lấy argUser, nếu null thì lấy sessionUser
    final user = argUser ?? sessionUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không tìm thấy thông tin tài khoản'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<SessionProvider>().clear();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (r) => false);
                },
                child: const Text("Quay lại đăng nhập"),
              )
            ],
          ),
        ),
      );
    }

    final fullname = user['fullname']?.toString() ?? '';

    return Scaffold(
      drawer: StaffDrawer(
        user: user,
        onSelect: (p) {
          setState(() => _page = p);
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        title: Text('Nhân viên: $fullname'),
      ),
      body: _buildPage(user),

      // Nút quét mã chỉ hiện ở tab SẢN PHẨM
      floatingActionButton: _page == 'products'
          ? FloatingActionButton(
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScanAddProductPage(),
                  ),
                );

                if (!mounted) return;

                if (added == true) {
                  _productsKey.currentState?.reload();
                }
              },
              child: const Icon(Icons.qr_code_scanner),
            )
          : null,
    );
  }

  Widget _buildPage(Map<String, dynamic> user) {
    switch (_page) {
      case 'products':
        return StaffProducts(
          key: _productsKey,
          user: user,
        );

      case 'import':
        return StaffImport(user: user);

      case 'export':
        return StaffExport(user: user);

      // [MỚI] Case hiển thị danh sách tin nhắn cho nhân viên
      case 'chat_list':
        return const AdminChatListPage(); // Dùng chung màn hình với Admin

      case 'dashboard':
      default:
        return const AdminDashboard();
    }
  }
}
