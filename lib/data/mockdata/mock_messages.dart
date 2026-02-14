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
      preview: 'CV cua ban rat phu hop, minh co the trao doi them',
      time: '09:24',
      unreadCount: 2,
      isPinned: true,
      isTyping: false,
      isOnline: true,
      tag: 'Phong van',
      location: 'Ha Noi',
      salary: '28-35 trieu',
      avatarText: 'TN',
      avatarColor: 0xFF0E7490,
    ),
    MessageThread(
      id: 't2',
      company: 'BlueOrbit Studio',
      role: 'UI/UX Designer',
      preview: 'Ban co the gui them portfolio gan day khong?',
      time: 'Hom qua',
      unreadCount: 1,
      isPinned: false,
      isTyping: true,
      isOnline: true,
      tag: 'Dang tu van',
      location: 'Remote',
      salary: '20-26 trieu',
      avatarText: 'BO',
      avatarColor: 0xFF4338CA,
    ),
    MessageThread(
      id: 't3',
      company: 'HealthFirst',
      role: 'Product Analyst',
      preview: 'Cam on ban da tham gia phong van ngay hom nay',
      time: 'Thu 5',
      unreadCount: 0,
      isPinned: false,
      isTyping: false,
      isOnline: false,
      tag: 'Da phong van',
      location: 'TP HCM',
      salary: '18-24 trieu',
      avatarText: 'HF',
      avatarColor: 0xFF16A34A,
    ),
    MessageThread(
      id: 't4',
      company: 'PixelPeak',
      role: 'Frontend Engineer',
      preview: 'De nghi luong cua ban la bao nhieu?',
      time: '07:50',
      unreadCount: 0,
      isPinned: true,
      isTyping: false,
      isOnline: true,
      tag: 'Dang tu van',
      location: 'Da Nang',
      salary: '25-32 trieu',
      avatarText: 'PP',
      avatarColor: 0xFFDB2777,
    ),
    MessageThread(
      id: 't5',
      company: 'GreenPulse',
      role: 'Marketing Specialist',
      preview: 'Minh gui ban thong tin ve thu moi nhan viec',
      time: '09/02',
      unreadCount: 0,
      isPinned: false,
      isTyping: false,
      isOnline: false,
      tag: 'De nghi',
      location: 'Ha Noi',
      salary: '16-20 trieu',
      avatarText: 'GP',
      avatarColor: 0xFF0F766E,
    ),
  ];

  static const Map<String, List<MessageBubble>> _conversations = {
    't1': [
      MessageBubble(
        type: MessageBubbleType.system,
        isFromEmployer: false,
        text: 'Ban da ket noi voi TechNova',
        time: '08:30',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Chao ban, ben minh da xem CV va rat an tuong ve kinh nghiem Flutter.',
        time: '08:45',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Ban co the chia se them ve du an gan day nhat khong?',
        time: '08:46',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Chao anh chi, em vua hoan thanh ung dung dat lich kham, em se gui them thong tin nhe.',
        time: '08:55',
      ),
      MessageBubble(
        type: MessageBubbleType.offerCard,
        isFromEmployer: true,
        text: '',
        time: '09:05',
        cardTitle: 'Buoi phong van ky thuat',
        cardSubtitle: 'Thu 2, 9:00 - 10:00',
        cardMeta: 'Zoom - de link trong email',
        ctaLabel: 'Xem lich',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Da ro, em se tham gia dung gio.',
        time: '09:12',
      ),
    ],
    't2': [
      MessageBubble(
        type: MessageBubbleType.system,
        isFromEmployer: false,
        text: 'BlueOrbit Studio da xem ho so cua ban',
        time: '16:10',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Chao ban, ben minh can them mot vai case study ve san pham di dong.',
        time: '16:13',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Em se gui them file Figma trong chieu nay.',
        time: '16:18',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Ban co the gui them portfolio gan day khong?',
        time: '09:05',
      ),
    ],
    't3': [
      MessageBubble(
        type: MessageBubbleType.system,
        isFromEmployer: false,
        text: 'Phong van hoan tat',
        time: '14:00',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Cam on ban da tham gia phong van, chung toi se phan hoi trong 2 ngay.',
        time: '14:05',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Cam on anh chi, em mong nhan phan hoi tu cong ty.',
        time: '14:10',
      ),
    ],
    't4': [
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'De nghi luong cua ban la bao nhieu de ben minh can doi ngan sach?',
        time: '07:50',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Em mong muon khoang 28-32 trieu, tuy theo pham vi cong viec.',
        time: '08:02',
      ),
    ],
    't5': [
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: true,
        text: 'Minh gui ban thong tin ve thu moi nhan viec trong file dinh kem nhe.',
        time: '09/02',
      ),
      MessageBubble(
        type: MessageBubbleType.offerCard,
        isFromEmployer: true,
        text: '',
        time: '09/02',
        cardTitle: 'Thu moi nhan viec',
        cardSubtitle: 'Marketing Specialist',
        cardMeta: '16-20 trieu · Bat dau 01/03',
        ctaLabel: 'Xem thu moi',
      ),
      MessageBubble(
        type: MessageBubbleType.text,
        isFromEmployer: false,
        text: 'Em da xem va se phan hoi trong hom nay.',
        time: '09/02',
      ),
    ],
  };

  static List<MessageBubble> getConversation(String threadId) {
    return _conversations[threadId] ?? const [];
  }
}
