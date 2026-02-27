import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AdminProductDetail extends StatefulWidget {
  final Map product;

  const AdminProductDetail({super.key, required this.product});

  @override
  State<AdminProductDetail> createState() => _AdminProductDetailState();
}

class _AdminProductDetailState extends State<AdminProductDetail> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Uint8List? _newImageBytes;
  String? _newImageName;

  String? oldImage; // tên file cũ

  bool saving = false;
  bool loadingDropdown = true;

  List categories = [];
  List suppliers = [];

  int? selectedCategory;
  int? selectedSupplier;

  @override
  void initState() {
    super.initState();

    // Gán giá trị ban đầu
    _nameCtrl.text = widget.product["name"] ?? "";
    _priceCtrl.text = widget.product["price"].toString();
    _qtyCtrl.text = widget.product["quantity"].toString();
    _descCtrl.text = widget.product["description"] ?? "";

    oldImage = widget.product["image"];

    selectedCategory = int.tryParse(widget.product["category_id"].toString());
    selectedSupplier = int.tryParse(widget.product["supplier_id"].toString());

    _loadDropdown();
  }

  Future<void> _loadDropdown() async {
    try {
      categories = await ApiService.getCategories();
      suppliers = await ApiService.getSuppliers();
    } catch (e) {
      debugPrint("Lỗi load dropdown: $e");
    }
    setState(() => loadingDropdown = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _newImageBytes = bytes;
      _newImageName = picked.name;
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _priceCtrl.text.trim().isEmpty ||
        _qtyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tên, giá, số lượng không được trống")));
      return;
    }

    setState(() => saving = true);

    String finalImage = oldImage ?? "";

    // Nếu chọn ảnh mới → upload
    if (_newImageBytes != null && _newImageName != null) {
      final filename =
          await ApiService.uploadImage(_newImageBytes!, _newImageName!);
      if (filename != null) finalImage = filename;
    }

    // Gửi thông tin update
    final body = {
      "id": widget.product["id"].toString(),
      "name": _nameCtrl.text.trim(),
      "price": _priceCtrl.text.trim(),
      "quantity": _qtyCtrl.text.trim(),
      "description": _descCtrl.text.trim(),
      "category_id": selectedCategory.toString(),
      "supplier_id": selectedSupplier.toString(),
      "image": finalImage,
    };

    final ok = await ApiService.updateProduct(body);

    setState(() => saving = false);

    if (!mounted) return;

    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    if (loadingDropdown) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String imageUrl = "${ApiService.baseUrl}/uploads/$oldImage";

    return Scaffold(
      appBar: AppBar(title: const Text("Sửa sản phẩm")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: _newImageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_newImageBytes!, fit: BoxFit.cover),
                      )
                    : Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Tên sản phẩm"),
            ),
            TextField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: "Giá sản phẩm"),
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

            // Dropdown Category
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
            const SizedBox(height: 15),

            // Dropdown Supplier
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

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text("Lưu thay đổi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
