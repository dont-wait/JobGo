enum MessageBubbleType {
  text,
  offerCard,
  system,
}

class MessageThread {
  final String id;
  final String company;
  final String role;
  final String preview;
  final String time;
  final int unreadCount;
  final bool isPinned;
  final bool isTyping;
  final bool isOnline;
  final String tag;
  final String location;
  final String salary;
  final String avatarText;
  final int avatarColor;

  const MessageThread({
    required this.id,
    required this.company,
    required this.role,
    required this.preview,
    required this.time,
    required this.unreadCount,
    required this.isPinned,
    required this.isTyping,
    required this.isOnline,
    required this.tag,
    required this.location,
    required this.salary,
    required this.avatarText,
    required this.avatarColor,
  });
}

class MessageBubble {
  final MessageBubbleType type;
  final bool isFromEmployer;
  final String text;
  final String time;
  final String? cardTitle;
  final String? cardSubtitle;
  final String? cardMeta;
  final String? ctaLabel;

  const MessageBubble({
    required this.type,
    required this.isFromEmployer,
    required this.text,
    required this.time,
    this.cardTitle,
    this.cardSubtitle,
    this.cardMeta,
    this.ctaLabel,
  });
}

class MockMessages {
  static const List<MessageThread> threads = [
    MessageThread(
      id: 't1',
      company: 'TechNova',
      role: 'Flutter Developer',
      preview: 'CV của bạn rất phù hợp, mình có thể trao đổi thêm',
      time: '09:24',
      unreadCount: 2,
      isPinned: true,
      isTyping: false,
      isOnline: true,
      tag: 'Phỏng vấn',
      location: 'Hà Nội',
      salary: '28-35 triệu',
      avatarText: 'TN',
      avatarColor: 0xFF0E7490,
    ),
    MessageThread(
      id: 't2',
      company: 'BlueOrbit Studio',
      role: 'UI/UX Designer',
      preview: 'Bạn có thể gửi thêm portfolio gần đây không?',
      time: 'Hôm qua',
      unreadCount: 1,
      isPinned: false,
      isTyping: true,
      isOnline: true,
      tag: 'Đang tư vấn',
      location: 'Remote',
      salary: '20-26 triệu',
      avatarText: 'BO',
      avatarColor: 0xFF4338CA,
    ),
    MessageThread(
      id: 't3',
      company: 'HealthFirst',
      role: 'Product Analyst',
      preview: 'Cảm ơn bạn đã tham gia phỏng vấn ngày hôm nay',
      time: 'Thứ 5',
      unreadCount: 0,
      isPinned: false,
      isTyping: false,
      isOnline: false,
      tag: 'Đã phỏng vấn',
      location: 'TP HCM',
      salary: '18-24 triệu',
      avatarText: 'HF',
      avatarColor: 0xFF16A34A,
    ),
    MessageThread(
      id: 't4',
      company: 'PixelPeak',
      role: 'Frontend Engineer',
      preview: 'Đề nghị lương của bạn là bao nhiêu?',
      time: '07:50',
      unreadCount: 0,
      isPinned: true,
      isTyping: false,
      isOnline: true,
      tag: 'Đang tư vấn',
      location: 'Đà Nẵng',
      salary: '25-32 triệu',
      avatarText: 'PP',
      avatarColor: 0xFFDB2777,
    ),
    MessageThread(
      id: 't5',
      company: 'GreenPulse',
      role: 'Marketing Specialist',
      preview: 'Mình gửi bạn thông tin về thư mời nhận việc',
      time: '09/02',
      unreadCount: 0,
      isPinned: false,
      isTyping: false,
      isOnline: false,
      tag: 'Đề nghị',
      location: 'Hà Nội',
      salary: '16-20 triệu',
      avatarText: 'GP',
      avatarColor: 0xFF0F766E,
    ),
  ];

  static const Map<String, List<MessageBubble>> _conversations = {
    't1': [
      MessageBubble(
        type: MessageBubbleType.system,
        isFromEmployer: false,
        text: 'Bạn đã kết nối với TechNova',
        time: '08:30',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Chào bạn, bên mình đã xem CV và rất ấn tượng về kinh nghiệm Flutter.',
        time: '08:45',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Bạn có thể chia sẻ thêm về dự án gần đây nhất không?',
        time: '08:46',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Chào anh/chị, em vừa hoàn thành ứng dụng đặt lịch khám, em sẽ gửi thêm thông tin nhé.',
        time: '08:55',
      ),
      MessageBubble(
        type: MessageBubbleType.offerCard,
        isFromEmployer: true,
        text: '',
        time: '09:05',
        cardTitle: 'Buổi phỏng vấn kỹ thuật',
        cardSubtitle: 'Thứ 2, 9:00 - 10:00',
        cardMeta: 'Zoom - để link trong email',
        ctaLabel: 'Xem lịch',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Đã rõ, em sẽ tham gia đúng giờ.',
        time: '09:12',
      ),
    ],
    't2': [
      MessageBubble(
        type: MessageBubbleType.system,
        isFromEmployer: false,
        text: 'BlueOrbit Studio đã xem hồ sơ của bạn',
        time: '16:10',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Chào bạn, bên mình cần thêm một vài case study về sản phẩm di động.',
        time: '16:13',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Em sẽ gửi thêm file Figma trong chiều nay.',
        time: '16:18',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Bạn có thể gửi thêm portfolio gần đây không?',
        time: '09:05',
      ),
    ],
    't3': [
      MessageBubble(
        type: MessageBubbleType.system,
        isFromEmployer: false,
        text: 'Phỏng vấn hoàn tất',
        time: '14:00',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Cảm ơn bạn đã tham gia phỏng vấn, chúng tôi sẽ phản hồi trong 2 ngày.',
        time: '14:05',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Cảm ơn anh/chị, em mong nhận phản hồi từ công ty.',
        time: '14:10',
      ),
    ],
    't4': [
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Đề nghị lương của bạn là bao nhiêu để bên mình cân đối ngân sách?',
        time: '07:50',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Em mong muốn khoảng 28-32 triệu, tùy theo phạm vi công việc.',
        time: '08:02',
      ),
    ],
    't5': [
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Mình gửi bạn thông tin về thư mời nhận việc trong file đính kèm nhé.',
        time: '09/02',
      ),
      MessageBubble(
        type: MessageBubbleType.offerCard,
        isFromEmployer: true,
        text: '',
        time: '09/02',
        cardTitle: 'Thư mời nhận việc',
        cardSubtitle: 'Marketing Specialist',
        cardMeta: '16-20 triệu · Bắt đầu 01/03',
        ctaLabel: 'Xem thư mời',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Em đã xem và sẽ phản hồi trong hôm nay.',
        time: '09/02',
      ),
    ],
  };

  static List<MessageBubble> getConversation(String threadId) {
    return _conversations[threadId] ?? const [];
  }
}
