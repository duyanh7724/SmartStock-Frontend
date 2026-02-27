import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminImportDetail extends StatefulWidget {
  final Map importOrder;

  const AdminImportDetail({super.key, required this.importOrder});

  @override
  State<AdminImportDetail> createState() => _AdminImportDetailState();
}

class _AdminImportDetailState extends State<AdminImportDetail> {
  bool loading = true;
  List details = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    details = await ApiService.getImportDetails(
        int.parse(widget.importOrder["id"].toString()));
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phiếu nhập #${widget.importOrder['id']}")),
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
                    subtitle: Text(
                        "SL: ${d['quantity']} • Giá: ${d['unit_price']} đ"),
                  ),
                );
              },
            ),
    );
  }
}
