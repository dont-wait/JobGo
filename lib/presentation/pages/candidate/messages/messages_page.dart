import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _searchQuery = '';

  // Dữ liệu mẫu (Demo Data)
  final List<Map<String, dynamic>> _dummyMessages = [
    {
      'name': 'Tech Solutions Inc.',
      'lastMessage': 'Chào bạn, chúng tôi đã nhận được CV của bạn. Xin vui lòng chờ phản hồi nhé!',
      'time': '10:00 AM',
      'isRead': false,
    },
    {
      'name': 'Global Corp',
      'lastMessage': 'Lịch phỏng vấn của bạn sẽ diễn ra vào ngày mai.',
      'time': 'Hôm qua',
      'isRead': true,
    },
    {
      'name': 'FPT Software',
      'lastMessage': 'Chúng tôi rất ấn tượng với profile của bạn.',
      'time': '3 ngày trước',
      'isRead': true,
    },
  ];

  Widget _buildMessageList(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) {
      return const Center(child: Text('Không tìm thấy tin nhắn nào.'));
    }
    return ListView.separated(
      itemCount: messages.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isRead = msg['isRead'] as bool? ?? true;
        
        return ListTile(
          leading: const CircleAvatar(
            radius: 25,
            child: Icon(Icons.business),
          ),
          title: Text(
            msg['name']?.toString() ?? '', 
            style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.bold),
          ),
          subtitle: Text(
            msg['lastMessage']?.toString() ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isRead ? Colors.grey : Colors.black87, 
              fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg['time']?.toString() ?? '', 
                style: TextStyle(color: isRead ? Colors.grey : Colors.blue, fontSize: 12),
              ),
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          onTap: () {
            // Bấm vào sẽ mở ra trang detail (có thể thiết kế tĩnh sau)
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _dummyMessages.where((msg) {
      final searchLower = _searchQuery.toLowerCase();
      return msg['name'].toString().toLowerCase().contains(searchLower) ||
             msg['lastMessage'].toString().toLowerCase().contains(searchLower);
    }).toList();

    final unreadMessages = filteredMessages.where((m) => m['isRead'] == false).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tin nhắn'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: Hiện bottom sheet các bộ lọc khác
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Chưa đọc'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tin nhắn...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMessageList(filteredMessages),
                  _buildMessageList(unreadMessages),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}