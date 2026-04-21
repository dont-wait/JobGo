import 'package:flutter/material.dart';

/// Chat user role in a conversation.
enum ChatUserRole { employer, candidate, admin }

/// Model representing a message thread.
class EmployerMessageThread {
  final String id;
  final String name;
  final String subtitle;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isPinned;
  final bool isOnline;
  final bool hasAttachment;
  final ChatUserRole userRole;
  final Color avatarColor;

  const EmployerMessageThread({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isPinned,
    required this.isOnline,
    required this.hasAttachment,
    required this.userRole,
    required this.avatarColor,
  });
}
