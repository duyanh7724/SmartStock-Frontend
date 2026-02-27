import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. GỬI TIN NHẮN
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    final timestamp = FieldValue.serverTimestamp();

    // Lưu tin nhắn vào collection
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
    });

    // Cập nhật thông tin phòng chat bên ngoài
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'lastMessage': message,
      'lastTime': timestamp,
      'customerId': chatRoomId,
    }, SetOptions(merge: true));
  }

  // 2. NHẬN TIN NHẮN (STREAM)
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // 3. LẤY DANH SÁCH PHÒNG CHAT (Cho Admin)
  Stream<QuerySnapshot> getChatRooms() {
    return _firestore
        .collection('chat_rooms')
        .orderBy('lastTime', descending: true)
        .snapshots();
  }
}
