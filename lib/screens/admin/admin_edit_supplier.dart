import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminEditSupplier extends StatefulWidget {
  final Map supplier;

  const AdminEditSupplier({super.key, required this.supplier});

  @override
  State<AdminEditSupplier> createState() => _AdminEditSupplierState();
}

class _AdminEditSupplierState extends State<AdminEditSupplier> {
  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.supplier["code"]);
    _nameCtrl = TextEditingController(text: widget.supplier["name"]);
    _addressCtrl = TextEditingController(text: widget.supplier["address"]);
    _phoneCtrl = TextEditingController(text: widget.supplier["phone"]);
  }

  Future<void> _save() async {
    if (_codeCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mã và tên không được để trống")));
      return;
    }

    setState(() => saving = true);

    final ok = await ApiService.updateSupplier(
      id: int.parse(widget.supplier["id"].toString()),
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    setState(() => saving = false);

    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa nhà cung cấp")),
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
                    : const Text("Cập nhật"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
