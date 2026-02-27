import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_add_category.dart';
import 'admin_edit_category.dart';

class AdminCategories extends StatefulWidget {
  const AdminCategories({super.key});

  @override
  State<AdminCategories> createState() => _AdminCategoriesState();
}

class _AdminCategoriesState extends State<AdminCategories> {
  bool loading = true;
  List categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final res = await ApiService.getCategories();
      setState(() {
        categories = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Lỗi load category: $e");
    }
  }

  Future<void> _deleteCategory(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa danh mục"),
        content: const Text("Bạn có chắc muốn xóa danh mục này không?"),
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

    if (confirm == true) {
      await ApiService.deleteCategory(id);
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh mục sản phẩm")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAddCategory()),
          );
          if (added == true) _loadCategories();
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text("Chưa có danh mục nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (_, i) {
                    final c = categories[i];
                    return Card(
                      child: ListTile(
                        title: Text(c["name"]),
                        subtitle: Text(c["description"] ?? ""),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AdminEditCategory(category: c),
                                  ),
                                );
                                if (updated == true) _loadCategories();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(
                                  int.parse(c["id"].toString())),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
