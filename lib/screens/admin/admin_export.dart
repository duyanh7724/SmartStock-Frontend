import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_export_create.dart';
import 'admin_export_detail.dart';

class AdminExport extends StatefulWidget {
  const AdminExport({super.key});

  @override
  State<AdminExport> createState() => _AdminExportState();
}

class _AdminExportState extends State<AdminExport> {
  bool loading = true;
  List exports = [];

  @override
  void initState() {
    super.initState();
    _loadExports();
  }

  Future<void> _loadExports() async {
    final data = await ApiService.getExports();
    setState(() {
      exports = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phiếu xuất hàng")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminExportCreate()),
          );
          if (created == true) _loadExports();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : exports.isEmpty
              ? const Center(child: Text("Chưa có phiếu xuất nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exports.length,
                  itemBuilder: (_, i) {
                    final e = exports[i];
                    return Card(
                      child: ListTile(
                        title: Text("Phiếu xuất #${e['id']}"),
                        subtitle: Text("Ngày: ${e['created_at']}"),
                        leading: const Icon(Icons.outbox),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminExportDetail(exportOrder: e),
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
