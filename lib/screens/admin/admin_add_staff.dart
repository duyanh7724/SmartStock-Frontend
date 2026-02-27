import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminAddStaff extends StatefulWidget {
  const AdminAddStaff({super.key});

  @override
  State<AdminAddStaff> createState() => _AdminAddStaffState();
}

class _AdminAddStaffState extends State<AdminAddStaff> {
  final _fullnameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = "staff";
  bool saving = false;

  Future<void> _save() async {
    if (_fullnameCtrl.text.trim().isEmpty ||
        _usernameCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vui lòng nhập đủ họ tên, username, mật khẩu")),
      );
      return;
    }

    setState(() => saving = true);

    final ok = await ApiService.addUser(
      fullname: _fullnameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      role: _role,
    );

    setState(() => saving = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm tài khoản thất bại")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm tài khoản / nhân viên")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _fullnameCtrl,
              decoration: const InputDecoration(labelText: "Họ tên"),
            ),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: "Tên đăng nhập"),
            ),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: "Vai trò"),
              items: const [
                DropdownMenuItem(value: "admin", child: Text("Admin")),
                DropdownMenuItem(value: "staff", child: Text("Nhân viên kho")),
                DropdownMenuItem(value: "customer", child: Text("Khách hàng")),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _role = v);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text("Lưu"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
