// lib/screens/staff/staff_import.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../admin/admin_import_detail.dart';
import 'staff_import_create.dart';

class StaffImport extends StatefulWidget {
  final Map<String, dynamic> user;

  const StaffImport({super.key, required this.user});

  @override
  State<StaffImport> createState() => _StaffImportState();
}

class _StaffImportState extends State<StaffImport> {
  bool loading = true;
  List imports = [];
  late int userId;

  @override
  void initState() {
    super.initState();
    userId = int.tryParse(widget.user['id'].toString()) ?? 0;
    _loadImports();
  }

  Future<void> _loadImports() async {
    try {
      final data = await ApiService.getImports();
      setState(() {
        imports = userId > 0
            ? data
                .where(
                  (imp) => imp['user_id'].toString() == userId.toString(),
                )
                .toList()
            : data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Lỗi load import (staff): $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phiếu nhập (Nhân viên của bạn)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StaffImportCreate(userId: userId),
            ),
          );
          if (created == true) _loadImports();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : imports.isEmpty
              ? const Center(
                  child: Text('Bạn chưa tạo phiếu nhập nào'),
                )
              : RefreshIndicator(
                  onRefresh: _loadImports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: imports.length,
                    itemBuilder: (_, i) {
                      final imp = imports[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.inventory),
                          title: Text('Phiếu nhập #${imp['id']}'),
                          subtitle: Text('Ngày: ${imp['created_at']}'),
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
                ),
    );
  }
}
