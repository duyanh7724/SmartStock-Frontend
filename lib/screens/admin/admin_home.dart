// lib/screens/admin/admin_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Thay đổi đường dẫn import nếu cần thiết cho phù hợp với dự án của bạn
import '../../widgets/drawer_admin.dart';
import '../../providers/session_provider.dart';

// Các màn hình admin
import 'admin_dashboard.dart';
import 'admin_finance_page.dart';
import 'admin_products.dart';
import 'admin_categories.dart';
import 'admin_suppliers.dart';
import 'admin_import.dart';
import 'admin_export.dart';
import 'admin_orders.dart';
import 'admin_staff.dart';
import 'admin_logs.dart';
import 'admin_bank_page.dart';
import 'admin_chat_list.dart'; // [MỚI] Import màn hình danh sách chat

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // Mặc định vào dashboard
  String page = "dashboard";

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Xác nhận"),
            content: const Text("Bạn có chắc muốn đăng xuất?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;
    if (!mounted) return;

    // Xóa user trong SessionProvider
    context.read<SessionProvider>().clear();

    // Điều hướng về màn login, clear toàn bộ stack
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer dùng chung
      drawer: AdminDrawer(
        onSelect: (p) {
          setState(() => page = p);
          // Đóng drawer sau khi chọn
          Navigator.pop(context);
        },
        onLogout: _handleLogout,
      ),
      // AppBar đổi title theo trang nếu muốn, ở đây để cố định
      appBar: AppBar(title: const Text("SmartStock Admin")),
      body: _buildPage(),
    );
  }

  // Hàm điều hướng hiển thị nội dung chính
  Widget _buildPage() {
    switch (page) {
      case "dashboard":
        return const AdminDashboard();

      case "finance":
        return const AdminFinancePage();

      case "products":
        return const AdminProducts();
      case "categories":
        return const AdminCategories();
      case "suppliers":
        return const AdminSuppliers();
      case "import":
        return const AdminImport();
      case "export":
        return const AdminExport();
      case "orders":
        return const AdminOrders();
      case "staff":
        return const AdminStaff();
      case "logs":
        return const AdminLogsPage();
      case "bank":
        return const AdminBankPage();

      // [MỚI] Case xử lý khi Admin chọn menu "Tin nhắn hỗ trợ"
      case "chat_list":
        return const AdminChatListPage();

      default:
        return const Center(child: Text("Chức năng đang phát triển"));
    }
  }
}
