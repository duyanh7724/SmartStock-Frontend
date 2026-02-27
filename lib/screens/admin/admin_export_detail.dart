import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminExportDetail extends StatefulWidget {
  final Map exportOrder;

  const AdminExportDetail({super.key, required this.exportOrder});

  @override
  State<AdminExportDetail> createState() => _AdminExportDetailState();
}

class _AdminExportDetailState extends State<AdminExportDetail> {
  bool loading = true;
  List details = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    details = await ApiService.getExportDetails(
        int.parse(widget.exportOrder["id"].toString()));
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phiếu xuất #${widget.exportOrder['id']}")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: details.length,
              itemBuilder: (_, i) {
                final d = details[i];
                return Card(
                  child: ListTile(
                    title: Text(d["product_name"]),
                    subtitle:
                        Text("SL: ${d['quantity']} • Giá: ${d['price']} đ"),
                  ),
                );
              },
            ),
    );
  }
}
