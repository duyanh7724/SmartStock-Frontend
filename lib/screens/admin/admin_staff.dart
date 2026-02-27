import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_add_staff.dart';
import 'admin_edit_staff.dart';

class AdminStaff extends StatefulWidget {
  const AdminStaff({super.key});

  @override
  State<AdminStaff> createState() => _AdminStaffState();
}

class _AdminStaffState extends State<AdminStaff> {
  bool loading = true;
  List users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await ApiService.getUsers();
    setState(() {
      users = data;
      loading = false;
    });
  }

  Future<void> _deleteUser(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa tài khoản"),
        content: const Text("Bạn có chắc muốn xóa tài khoản này không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok == true) {
      await ApiService.deleteUser(id);
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý tài khoản / nhân viên")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAddStaff()),
          );
          if (added == true) _loadUsers();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text("Chưa có tài khoản nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(u["fullname"]),
                        subtitle: Text(
                            "User: ${u['username']} • Vai trò: ${u['role']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminEditStaff(user: u),
                                  ),
                                );
                                if (updated == true) _loadUsers();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(
                                int.parse(u["id"].toString()),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
