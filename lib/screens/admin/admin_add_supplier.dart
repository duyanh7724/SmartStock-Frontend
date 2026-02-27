import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminAddSupplier extends StatefulWidget {
  const AdminAddSupplier({super.key});

  @override
  State<AdminAddSupplier> createState() => _AdminAddSupplierState();
}

class _AdminAddSupplierState extends State<AdminAddSupplier> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool saving = false;

  Future<void> _save() async {
    if (_codeCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nhập mã và tên nhà cung cấp")));
      return;
    }

    setState(() => saving = true);

    final ok = await ApiService.addSupplier(
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    setState(() => saving = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Thêm thất bại")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm nhà cung cấp")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: "Mã NCC")),
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Tên NCC")),
            TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: "Địa chỉ")),
            TextField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: "SĐT")),
            const SizedBox(height: 20),
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
