import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_import_create.dart';
import 'admin_import_detail.dart';

class AdminImport extends StatefulWidget {
  const AdminImport({super.key});

  @override
  State<AdminImport> createState() => _AdminImportState();
}

class _AdminImportState extends State<AdminImport> {
  bool loading = true;
  List imports = [];

  @override
  void initState() {
    super.initState();
    _loadImports();
  }

  Future<void> _loadImports() async {
    try {
      final data = await ApiService.getImports();
      setState(() {
        imports = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Lỗi load import orders: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phiếu nhập hàng")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminImportCreate()),
          );
          if (created == true) _loadImports();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : imports.isEmpty
              ? const Center(child: Text("Chưa có phiếu nhập nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: imports.length,
                  itemBuilder: (_, i) {
                    final imp = imports[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.inventory),
                        title: Text("Phiếu nhập #${imp['id']}"),
                        subtitle: Text("Ngày: ${imp['created_at']}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminImportDetail(importOrder: imp),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
