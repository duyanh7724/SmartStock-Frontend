import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Cần thêm intl vào pubspec.yaml nếu muốn format ngày giờ đẹp
import '../../services/chat_service.dart';
import '../chat/chat_page.dart';

class AdminChatListPage extends StatefulWidget {
  const AdminChatListPage({super.key});

  @override
  State<AdminChatListPage> createState() => _AdminChatListPageState();
}

class _AdminChatListPageState extends State<AdminChatListPage> {
  final ChatService _chatService = ChatService();

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    return DateFormat('HH:mm dd/MM')
        .format(date); // Cần thư viện intl, hoặc dùng date.toString() tạm
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hỗ trợ khách hàng")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có tin nhắn nào."));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final roomId = docs[index].id;

              // Lấy thông tin hiển thị
              // Nếu bạn đã lưu customerName lúc gửi tin thì lấy ra, nếu chưa thì hiển thị ID tạm
              final name = "Khách hàng #$roomId";
              final lastMsg = data['lastMessage'] ?? "";
              final lastTime = data['lastTime'] as Timestamp?;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Text(
                  _formatTime(lastTime),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  // Admin bấm vào thì chuyển sang màn hình ChatPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatRoomId: roomId,
                        chatTitle: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
