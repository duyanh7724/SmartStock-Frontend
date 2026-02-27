import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminAddCategory extends StatefulWidget {
  const AdminAddCategory({super.key});

  @override
  State<AdminAddCategory> createState() => _AdminAddCategoryState();
}

class _AdminAddCategoryState extends State<AdminAddCategory> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool saving = false;

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên danh mục")),
      );
      return;
    }

    setState(() => saving = true);

    final ok = await ApiService.addCategory(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );

    setState(() => saving = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm thất bại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm danh mục")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Tên danh mục"),
            ),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: "Mô tả"),
              maxLines: 2,
            ),
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
