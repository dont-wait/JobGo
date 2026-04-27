class NotificationModel {
  final int id;
  final String type;
  final String content;
  final String status;
  final DateTime? createdAt;
  final int userId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _toInt(json['n_id']) ?? 0,
      type: _toString(json['n_type']) ?? 'system',
      content: _toString(json['n_content']) ?? '',
      status: _toString(json['n_status']) ?? 'unread',
      createdAt: _toDateTime(json['n_create_at']),
      userId: _toInt(json['u_id']) ?? 0,
    );
  }

  bool get isRead => status.toLowerCase() == 'read';

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.toLowerCase() == 'null' ? null : str;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
