/// Model đại diện cho 1 "cuộc hội thoại" (nhóm tin nhắn giữa 2 user).
/// Được tạo từ việc nhóm các dòng trong bảng `messages` theo cặp sender_id/receiver_id.
class ConversationModel {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? otherUserRole;
  final ChatMessageModel? lastMessage;
  final int unreadCount;

  const ConversationModel({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.otherUserRole,
    this.lastMessage,
    this.unreadCount = 0,
  });

  /// Tên hiển thị.
  String get displayName =>
      otherUserName.isNotEmpty ? otherUserName : 'User #$otherUserId';

  ConversationModel copyWith({
    ChatMessageModel? lastMessage,
    int? unreadCount,
  }) {
    return ConversationModel(
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserAvatar: otherUserAvatar,
      otherUserRole: otherUserRole,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Model đại diện cho 1 tin nhắn trong bảng `messages`.
class ChatMessageModel {
  final int id;         // m_id
  final int senderId;   // sender_id
  final int receiverId; // receiver_id
  final String content; // m_content
  final String status;  // m_status: 'sent' | 'delivered' | 'read'
  final DateTime sentAt; // m_sent_at

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.status = 'sent',
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['m_sent_at'] != null) {
      final val = json['m_sent_at'];
      if (val is DateTime) {
        parsedDate = val.isUtc ? val.toLocal() : val;
      } else {
        final dateStr = val.toString();
        if (!dateStr.endsWith('Z') && !dateStr.contains('+') && !dateStr.contains('-')) {
          // Coi chuỗi không múi giờ là UTC từ DB và đổi sang Local của thiết bị
          parsedDate = DateTime.parse('${dateStr.replaceAll(' ', 'T')}Z').toLocal();
        } else {
          parsedDate = DateTime.parse(dateStr).toLocal();
        }
      }
    } else {
      parsedDate = DateTime.now();
    }

    return ChatMessageModel(
      id: _toInt(json['m_id']) ?? 0,
      senderId: _toInt(json['sender_id']) ?? 0,
      receiverId: _toInt(json['receiver_id']) ?? 0,
      content: json['m_content'] as String? ?? '',
      status: json['m_status'] as String? ?? 'sent',
      sentAt: parsedDate,
    );
  }

  bool isMe(int currentUserId) => senderId == currentUserId;

  /// ID của người còn lại trong cuộc hội thoại.
  int otherUserId(int currentUserId) =>
      senderId == currentUserId ? receiverId : senderId;

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
