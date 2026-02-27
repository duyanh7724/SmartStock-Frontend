// lib/screens/scan_add_product.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'admin/add_product.dart';

class ScanAddProductPage extends StatefulWidget {
  const ScanAddProductPage({super.key});

  @override
  State<ScanAddProductPage> createState() => _ScanAddProductPageState();
}

class _ScanAddProductPageState extends State<ScanAddProductPage> {
  String? _lastCode;
  bool _locked = false; // khoá để không xử lý trùng nhiều lần

  void _onDetect(BarcodeCapture capture) {
    if (_locked) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _lastCode = code;
      _locked = true;
    });

    _showResultDialog(code);
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Đã quét mã'),
        content: Text('Mã: $code'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _locked = false);
              Navigator.of(context).pop(); // đóng dialog, quét lại tiếp
            },
            child: const Text('Quét lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // đóng dialog
              // Chuyển sang màn thêm sản phẩm, kèm ghi chú mã quét
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductPage(initialNote: 'Mã quét: $code'),
                ),
              );
            },
            child: const Text('Tạo sản phẩm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã sản phẩm')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          if (_lastCode != null)
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.all(12),
              child: Text(
                'Mã gần nhất: $_lastCode',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
