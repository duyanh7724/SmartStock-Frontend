import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_add_supplier.dart';
import 'admin_edit_supplier.dart';

class AdminSuppliers extends StatefulWidget {
  const AdminSuppliers({super.key});

  @override
  State<AdminSuppliers> createState() => _AdminSuppliersState();
}

class _AdminSuppliersState extends State<AdminSuppliers> {
  bool loading = true;
  List suppliers = [];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final data = await ApiService.getSuppliers();
      setState(() {
        suppliers = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Lỗi load nhà cung cấp: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _deleteSupplier(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa nhà cung cấp"),
        content: const Text("Bạn có chắc muốn xóa nhà cung cấp này không?"),
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
      await ApiService.deleteSupplier(id);
      _loadSuppliers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nhà cung cấp")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAddSupplier()),
          );
          if (ok == true) _loadSuppliers();
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : suppliers.isEmpty
              ? const Center(child: Text("Chưa có nhà cung cấp nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suppliers.length,
                  itemBuilder: (_, i) {
                    final s = suppliers[i];
                    return Card(
                      child: ListTile(
                        title: Text("${s['name']} (${s['code']})"),
                        subtitle: Text(
                            "${s['address'] ?? ''}\n📞 ${s['phone'] ?? ''}"),
                        isThreeLine: true,
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
                                        AdminEditSupplier(supplier: s),
                                  ),
                                );
                                if (updated == true) _loadSuppliers();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSupplier(
                                  int.parse(s["id"].toString())),
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
