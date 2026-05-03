import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDetailScreen extends StatefulWidget {
  final int currentUserId;
  final int otherUserId;

  const ChatDetailScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    try {
      await Supabase.instance.client.from('messages').insert({
        'sender_id': widget.currentUserId,
        'receiver_id': widget.otherUserId,
        'm_content': text,
        'm_status': 'sent',
        // Cột m_sent_at sẽ tự động sinh thời gian nếu DB của bạn có set default NOW()
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi tin: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trò chuyện với ID: ${widget.otherUserId}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('messages').stream(primaryKey: ['m_id']),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allMessages = snapshot.data ?? [];
                // Lọc để chỉ lấy tin nhắn qua lại giữa 2 người này
                final chatMessages = allMessages.where((m) {
                  final s = m['sender_id'];
                  final r = m['receiver_id'];
                  return (s == widget.currentUserId && r == widget.otherUserId) ||
                         (s == widget.otherUserId && r == widget.currentUserId);
                }).toList();

                // Sắp xếp tin nhắn mới nhất lên đầu để dùng ListView reverse
                chatMessages.sort((a, b) {
                  final timeA = DateTime.tryParse(a['m_sent_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final timeB = DateTime.tryParse(b['m_sent_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return timeB.compareTo(timeA); 
                });

                if (chatMessages.isEmpty) {
                  return const Center(
                    child: Text('Hãy gửi lời chào để bắt đầu cuộc trò chuyện!'),
                  );
                }

                return ListView.builder(
                  reverse: true, // Cuộn từ dưới lên trên giống Messenger/Zalo
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = chatMessages[index];
                    final isMe = msg['sender_id'] == widget.currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['m_content'] ?? '',
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}