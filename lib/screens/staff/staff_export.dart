// lib/screens/staff/staff_export.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../admin/admin_export_detail.dart';
import 'staff_export_create.dart';

class StaffExport extends StatefulWidget {
  final Map<String, dynamic> user;

  const StaffExport({super.key, required this.user});

  @override
  State<StaffExport> createState() => _StaffExportState();
}

class _StaffExportState extends State<StaffExport> {
  bool loading = true;
  List exports = [];
  late int userId;

  @override
  void initState() {
    super.initState();
    userId = int.tryParse(widget.user['id'].toString()) ?? 0;
    _loadExports();
  }

  Future<void> _loadExports() async {
    try {
      final data = await ApiService.getExports();
      setState(() {
        exports = userId > 0
            ? data
                .where(
                  (e) => e['user_id'].toString() == userId.toString(),
                )
                .toList()
            : data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Lỗi load export (staff): $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phiếu xuất (Nhân viên của bạn)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StaffExportCreate(userId: userId),
            ),
          );
          if (created == true) _loadExports();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : exports.isEmpty
              ? const Center(
                  child: Text('Bạn chưa tạo phiếu xuất nào'),
                )
              : RefreshIndicator(
                  onRefresh: _loadExports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exports.length,
                    itemBuilder: (_, i) {
                      final e = exports[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.outbox),
                          title: Text('Phiếu xuất #${e['id']}'),
                          subtitle: Text('Ngày: ${e['created_at']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminExportDetail(
                                  exportOrder: e,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
