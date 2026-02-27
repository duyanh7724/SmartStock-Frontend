// lib/screens/admin/add_product.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AddProductPage extends StatefulWidget {
  final String? initialNote; // ghi chú từ màn quét mã (có thể null)

  const AddProductPage({super.key, this.initialNote});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  bool _saving = false;
  bool _loadingDropdown = true;

  List categories = [];
  List suppliers = [];

  int? selectedCategory;
  int? selectedSupplier;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();

    // Nếu được truyền ghi chú từ màn quét mã → set vào mô tả
    if (widget.initialNote != null && widget.initialNote!.isNotEmpty) {
      _descCtrl.text = widget.initialNote!;
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      categories = await ApiService.getCategories();
      suppliers = await ApiService.getSuppliers();

      if (categories.isNotEmpty) {
        selectedCategory = int.parse(categories.first["id"].toString());
      }
      if (suppliers.isNotEmpty) {
        selectedSupplier = int.parse(suppliers.first["id"].toString());
      }
    } catch (e) {
      debugPrint("Lỗi load dropdown: $e");
    }

    if (!mounted) return;
    setState(() => _loadingDropdown = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageName = picked.name;
    });
  }

  Future<void> _save() async {
    // validate sync trước khi có await → không warning
    if (_nameCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty ||
        _qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ tên, giá, số lượng")),
      );
      return;
    }

    if (selectedCategory == null || selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa chọn danh mục hoặc nhà cung cấp")),
      );
      return;
    }

    setState(() => _saving = true);

    String uploadedFilename = "";

    try {
      // Upload ảnh trước nếu có
      if (_imageBytes != null && _imageName != null) {
        final filename =
            await ApiService.uploadImage(_imageBytes!, _imageName!);
        if (filename != null) {
          uploadedFilename = filename;
        }
      }

      // Gửi body
      final body = {
        "name": _nameCtrl.text.trim(),
        "price": _priceCtrl.text.trim(),
        "quantity": _qtyCtrl.text.trim(),
        "description": _descCtrl.text.trim(),
        "category_id": selectedCategory.toString(),
        "supplier_id": selectedSupplier.toString(),
        "image": uploadedFilename, // PHẢI GỬI KEY "image"
      };

      final result = await ApiService.addProduct(body);

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? "Thêm sản phẩm thất bại")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingDropdown) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Thêm sản phẩm")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageBytes == null
                    ? const Icon(Icons.photo, size: 48)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Tên sản phẩm"),
            ),
            TextField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: "Giá"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _qtyCtrl,
              decoration: const InputDecoration(labelText: "Số lượng"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: "Mô tả"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // DANH MỤC
            DropdownButtonFormField<int>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: "Danh mục"),
              items: categories.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem(
                  value: int.parse(c["id"].toString()),
                  child: Text(c["name"]),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
            ),

            const SizedBox(height: 20),

            // NHÀ CUNG CẤP
            DropdownButtonFormField<int>(
              value: selectedSupplier,
              decoration: const InputDecoration(labelText: "Nhà cung cấp"),
              items: suppliers.map<DropdownMenuItem<int>>((s) {
                return DropdownMenuItem(
                  value: int.parse(s["id"].toString()),
                  child: Text("${s['name']} (${s['code']})"),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedSupplier = v),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Lưu sản phẩm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
