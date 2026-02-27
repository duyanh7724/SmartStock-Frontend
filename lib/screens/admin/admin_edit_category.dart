import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminEditCategory extends StatefulWidget {
  final Map category;

  const AdminEditCategory({super.key, required this.category});

  @override
  State<AdminEditCategory> createState() => _AdminEditCategoryState();
}

class _AdminEditCategoryState extends State<AdminEditCategory> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category["name"]);
    _descCtrl = TextEditingController(text: widget.category["description"]);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tên danh mục không được rỗng")),
      );
      return;
    }

    setState(() => saving = true);

    final ok = await ApiService.updateCategory(
      id: int.parse(widget.category["id"].toString()),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );

    setState(() => saving = false);

    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa danh mục")),
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
                    : const Text("Cập nhật"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
