// lib/services/api_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // BASE URL: Web = localhost | Android Emulator = 10.0.2.2
  // Lưu ý: Nếu chạy máy thật (Real Device), hãy thay localhost bằng IP LAN của máy tính (VD: 192.168.1.x)
  static final String baseUrl = kIsWeb
      ? "http://localhost/smartstock_api"
      : "http://10.0.2.2/smartstock_api";

  // ===================================================
  // LOGIN
  // ===================================================
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse("$baseUrl/login.php");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    return jsonDecode(res.body);
  }

  // ===================================================
  // REGISTER
  // ===================================================
  static Future<Map<String, dynamic>> register({
    required String fullname,
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/register.php");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": fullname,
        "username": username,
        "password": password,
      }),
    );

    return jsonDecode(res.body);
  }

  // ===================================================
  // GET PRODUCTS
  // ===================================================
  static Future<List<dynamic>> getProducts() async {
    final url = Uri.parse("$baseUrl/product/get_products.php");
    final res = await http.get(url);

    final data = jsonDecode(res.body);
    return data["data"];
  }

  // ===================================================
  // UPLOAD IMAGE
  // ===================================================
  static Future<String?> uploadImage(Uint8List bytes, String filename) async {
    final url = Uri.parse("$baseUrl/product/upload_image.php");

    final req = http.MultipartRequest("POST", url);
    req.files.add(
      http.MultipartFile.fromBytes("file", bytes, filename: filename),
    );

    final res = await req.send();
    final body = await res.stream.bytesToString();
    final json = jsonDecode(body);

    if (json["success"] == true) {
      return json["filename"];
    }
    return null;
  }

  // ===================================================
  // ADD PRODUCT
  // ===================================================
  static Future<Map<String, dynamic>> addProduct(
      Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/product/add_product.php");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  // ===================================================
  // DELETE PRODUCT
  // ===================================================
  static Future<bool> deleteProduct(int id) async {
    final url = Uri.parse("$baseUrl/product/delete_product.php?id=$id");
    final res = await http.get(url);

    final json = jsonDecode(res.body);
    return json["success"] == true;
  }

  // ===================================================
  // DASHBOARD STATS (OLD SIMPLE)
  // ===================================================
  static Future<Map<String, dynamic>> getDashboardStats() async {
    // Đây là file cũ, chỉ dùng nếu bạn muốn xem thống kê đơn giản
    final url = Uri.parse('$baseUrl/product/get_stats.php');
    final res = await http.get(url);

    final json = jsonDecode(res.body);
    return json["data"];
  }

  // GET CATEGORY
  static Future<List<dynamic>> getCategories() async {
    final url = Uri.parse("$baseUrl/category/get_categories.php");
    final res = await http.get(url);
    return jsonDecode(res.body)["data"];
  }

  // ADD CATEGORY
  static Future<bool> addCategory(
      {required String name, required String description}) async {
    final url = Uri.parse("$baseUrl/category/add_category.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "description": description}),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // UPDATE CATEGORY
  static Future<bool> updateCategory(
      {required int id,
      required String name,
      required String description}) async {
    final url = Uri.parse("$baseUrl/category/update_category.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id, "name": name, "description": description}),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // DELETE CATEGORY
  static Future<bool> deleteCategory(int id) async {
    final url = Uri.parse("$baseUrl/category/delete_category.php?id=$id");
    final res = await http.get(url);
    return jsonDecode(res.body)["success"] == true;
  }

  // GET SUPPLIERS
  static Future<List<dynamic>> getSuppliers() async {
    final url = Uri.parse("$baseUrl/supplier/get_suppliers.php");
    final res = await http.get(url);
    return jsonDecode(res.body)["data"];
  }

  // ADD SUPPLIER
  static Future<bool> addSupplier({
    required String code,
    required String name,
    required String address,
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/supplier/add_supplier.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "code": code,
        "name": name,
        "address": address,
        "phone": phone,
      }),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // UPDATE SUPPLIER
  static Future<bool> updateSupplier({
    required int id,
    required String code,
    required String name,
    required String address,
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/supplier/update_supplier.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "code": code,
        "name": name,
        "address": address,
        "phone": phone,
      }),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // DELETE SUPPLIER
  static Future<bool> deleteSupplier(int id) async {
    final url = Uri.parse("$baseUrl/supplier/delete_supplier.php?id=$id");
    final res = await http.get(url);
    return jsonDecode(res.body)["success"] == true;
  }

  static Future<bool> updateProduct(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/product/update_product.php");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(res.body)["success"] == true;
  }

  // GET IMPORT LIST
  static Future<List<dynamic>> getImports() async {
    final url = Uri.parse("$baseUrl/import/get_imports.php");
    final res = await http.get(url);
    return jsonDecode(res.body)["data"];
  }

  // CREATE IMPORT ORDER (old)
  static Future<bool> createImportOrder(List items) async {
    final url = Uri.parse("$baseUrl/import/create_import.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"items": items}),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // GET IMPORT ORDER DETAILS
  static Future<List<dynamic>> getImportDetails(int importId) async {
    final url =
        Uri.parse("$baseUrl/import/get_import_details.php?id=$importId");
    final res = await http.get(url);
    return jsonDecode(res.body)["data"];
  }

  // EXPORT ORDER LIST
  static Future<List<dynamic>> getExports() async {
    final url = Uri.parse("$baseUrl/export/get_exports.php");
    final res = await http.get(url);
    return jsonDecode(res.body)["data"];
  }

  // CREATE EXPORT (old)
  static Future<bool> createExportOrder(List items) async {
    final url = Uri.parse("$baseUrl/export/create_export.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"items": items}),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // GET EXPORT DETAIL
  static Future<List<dynamic>> getExportDetails(int id) async {
    final url = Uri.parse("$baseUrl/export/get_export_details.php?id=$id");
    final res = await http.get(url);
    return jsonDecode(res.body)["data"];
  }

  // ===================================================
  // ORDER (KHÁCH + ADMIN)
  // ===================================================

  /// ADMIN: lấy tất cả đơn hàng
  static Future<List<dynamic>> getAllOrders() async {
    final url = Uri.parse("$baseUrl/orders/get_orders.php");

    final res = await http.get(url);
    final json = jsonDecode(res.body);

    return json["data"] ?? [];
  }

  /// CUSTOMER: lấy đơn hàng theo user_id
  static Future<List<dynamic>> getOrders(int userId) async {
    final url = Uri.parse("$baseUrl/orders/get_orders.php?user_id=$userId");

    final res = await http.get(url);
    final json = jsonDecode(res.body);

    return json["data"] ?? [];
  }

  /// CUSTOMER: tạo đơn hàng từ app
  static Future<Map<String, dynamic>> createCustomerOrder(
      Map<String, dynamic> payload) async {
    final url = Uri.parse("$baseUrl/orders/create_order.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }

  /// Chi tiết đơn hàng
  static Future<List<dynamic>> getOrderDetail(int id) async {
    final url = Uri.parse("$baseUrl/orders/get_order_detail.php?id=$id");
    final res = await http.get(url);
    return jsonDecode(res.body)["data"];
  }

  /// Admin cập nhật trạng thái
  static Future<bool> updateOrderStatus({
    required int id,
    required String status,
  }) async {
    final url = Uri.parse("$baseUrl/orders/update_status.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "status": status,
      }),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  /// Admin xóa đơn
  static Future<bool> deleteOrder(int id) async {
    final url = Uri.parse("$baseUrl/orders/delete_order.php?id=$id");
    final res = await http.get(url);
    return jsonDecode(res.body)["success"] == true;
  }

  // ================= USERS / STAFF ==================

  static Future<List<dynamic>> getUsers() async {
    final url = Uri.parse("$baseUrl/users/get_users.php");
    final res = await http.get(url);
    return jsonDecode(res.body)["data"];
  }

  static Future<bool> addUser({
    required String fullname,
    required String username,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse("$baseUrl/users/add_user.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": fullname,
        "username": username,
        "password": password,
        "role": role,
      }),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  static Future<bool> updateUser({
    required int id,
    required String fullname,
    required String role,
    required String password, // có thể rỗng
  }) async {
    final url = Uri.parse("$baseUrl/users/update_user.php");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "fullname": fullname,
        "role": role,
        "password": password,
      }),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  static Future<bool> deleteUser(int id) async {
    final url = Uri.parse("$baseUrl/users/delete_user.php?id=$id");
    final res = await http.get(url);
    return jsonDecode(res.body)["success"] == true;
  }

  // ====================== NHẬP KHO (NEW, có user_id) ======================
  static Future<bool> addImportOrder(List items, int userId) async {
    final url = Uri.parse("$baseUrl/import/add_import.php");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "items": items,
      }),
    );

    final data = jsonDecode(res.body);
    return data["success"] == true;
  }

  // ====================== XUẤT KHO (NEW, có user_id) ======================
  static Future<bool> addExportOrder(List items, int userId) async {
    final url = Uri.parse("$baseUrl/export/add_export.php");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "items": items,
      }),
    );

    final data = jsonDecode(res.body);
    return data["success"] == true;
  }

  // ===================================================
  // FULL DASHBOARD (new)
  // ===================================================
  static Future<Map<String, dynamic>> getDashboardFull() async {
    // 🔥 ĐÃ SỬA: Trỏ vào file dashboard_full.php để lấy các chỉ số tài chính mới
    final url = Uri.parse("$baseUrl/product/dashboard_full.php");

    final res = await http.get(url);
    final json = jsonDecode(res.body);
    return json as Map<String, dynamic>;
  }

  // ===================================================
  // LOG HOẠT ĐỘNG
  // ===================================================
  static Future<Map<String, dynamic>> getLogs() async {
    final url = Uri.parse("$baseUrl/logs.php");
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ===================================================
  // LOG HOẠT ĐỘNG: chi tiết theo user
  // ===================================================
  static Future<Map<String, dynamic>> getUserActivity(int userId) async {
    final url = Uri.parse("$baseUrl/user_activity.php?user_id=$userId");
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ===================================================
  // NGÂN HÀNG: LẤY & CẬP NHẬT
  // ===================================================

  // 1. Lấy thông tin
  static Future<Map<String, dynamic>> getBankInfo() async {
    final url = Uri.parse("$baseUrl/bank/get_bank.php");
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      if (kDebugMode) print("Lỗi getBankInfo: $e");
    }
    return {};
  }

  // 2. Cập nhật
  static Future<bool> updateBankInfo({
    required String bankCode,
    required String bankName,
    required String accountName,
    required String accountNumber,
  }) async {
    final url = Uri.parse("$baseUrl/bank/update_bank.php");

    try {
      final res = await http.post(
        url,
        body: {
          "id": "1",
          "bank_code": bankCode,
          "bank_name": bankName,
          "account_name": accountName,
          "account_number": accountNumber,
        },
      );

      final json = jsonDecode(res.body);
      return json["status"] == "success";
    } catch (e) {
      if (kDebugMode) print("Lỗi updateBankInfo: $e");
      return false;
    }
  }
  // ... Các hàm cũ giữ nguyên ...

  // ===================================================
  // LOGIN GOOGLE (THÊM MỚI)
  // ===================================================
  static Future<Map<String, dynamic>> loginGoogle({
    required String email,
    required String googleId,
    required String fullname,
    required String avatar,
    String? fcmToken,
  }) async {
    final url = Uri.parse("$baseUrl/login_google.php");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "google_id": googleId,
          "fullname": fullname,
          "avatar": avatar,
          "fcm_token": fcmToken ?? "",
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
  // ... các hàm cũ ...

  // ===================================================
  // CẬP NHẬT FCM TOKEN (CHO THÔNG BÁO ĐẨY)
  // ===================================================
  static Future<void> updateFcmToken(int userId, String token) async {
    final url = Uri.parse(
        "$baseUrl/users/update_fcm_token.php"); // Sửa đường dẫn cho đúng vị trí file
    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "fcm_token": token,
        }),
      );
      print("FCM Token updated for user $userId");
    } catch (e) {
      print("Lỗi cập nhật FCM Token: $e");
    }
  }
}
