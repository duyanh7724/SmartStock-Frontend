import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final Function(String) onSelect;
  final VoidCallback? onLogout;

  const AdminDrawer({
    super.key,
    required this.onSelect,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person),
            ),
            accountName: Text("Quản trị viên"),
            accountEmail: Text("admin@smartstock.app"),
          ),
          Expanded(
            child: ListView(
              children: [
                _item(
                  icon: Icons.dashboard,
                  label: "Dashboard",
                  keyPage: "dashboard",
                ),

                // === MỤC BÁO CÁO TÀI CHÍNH ===
                _item(
                  icon: Icons.pie_chart,
                  label: "Báo cáo Tài chính",
                  keyPage: "finance",
                ),

                _item(
                  icon: Icons.inventory_2,
                  label: "Quản lý sản phẩm",
                  keyPage: "products",
                ),
                _item(
                  icon: Icons.category,
                  label: "Danh mục",
                  keyPage: "categories",
                ),
                _item(
                  icon: Icons.store,
                  label: "Nhà cung cấp",
                  keyPage: "suppliers",
                ),
                _item(
                  icon: Icons.download,
                  label: "Phiếu nhập",
                  keyPage: "import",
                ),
                _item(
                  icon: Icons.upload,
                  label: "Phiếu xuất",
                  keyPage: "export",
                ),
                _item(
                  icon: Icons.shopping_cart,
                  label: "Đơn hàng khách",
                  keyPage: "orders",
                ),

                // === [MỚI] MỤC TIN NHẮN HỖ TRỢ ===
                _item(
                  icon: Icons.chat_bubble_outline,
                  label: "Tin nhắn hỗ trợ",
                  keyPage: "chat_list",
                ),
                // =================================

                _item(
                  icon: Icons.people,
                  label: "Nhân viên",
                  keyPage: "staff",
                ),
                _item(
                  icon: Icons.history,
                  label: "Log hoạt động",
                  keyPage: "logs",
                ),
                _item(
                  icon: Icons.account_balance,
                  label: "Thông tin ngân hàng",
                  keyPage: "bank",
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.red),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  ListTile _item({
    required IconData icon,
    required String label,
    required String keyPage,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => onSelect(keyPage),
    );
  }
}
