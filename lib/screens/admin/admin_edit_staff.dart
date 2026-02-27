import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminEditStaff extends StatefulWidget {
  final Map user;

  const AdminEditStaff({super.key, required this.user});

  @override
  State<AdminEditStaff> createState() => _AdminEditStaffState();
}

class _AdminEditStaffState extends State<AdminEditStaff> {
  late TextEditingController _fullnameCtrl;
  final _passwordCtrl = TextEditingController();
  String _role = "staff";
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _fullnameCtrl = TextEditingController(text: widget.user["fullname"]);
    _role = widget.user["role"] ?? "staff";
  }

  Future<void> _save() async {
    if (_fullnameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Họ tên không được trống")),
      );
      return;
    }

    setState(() => saving = true);

    final ok = await ApiService.updateUser(
      id: int.parse(widget.user["id"].toString()),
      fullname: _fullnameCtrl.text.trim(),
      role: _role,
      password: _passwordCtrl.text.trim(), // có thể rỗng = không đổi
    );

    setState(() => saving = false);

    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa tài khoản")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Username: ${widget.user["username"]}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _fullnameCtrl,
              decoration: const InputDecoration(labelText: "Họ tên"),
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
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(
                  labelText: "Mật khẩu mới (bỏ trống nếu không đổi)"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text("Lưu thay đổi"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
