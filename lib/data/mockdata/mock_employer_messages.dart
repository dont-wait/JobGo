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

/// Mock data — messages for employer.
class MockEmployerMessages {
  MockEmployerMessages._();

  static const List<EmployerMessageThread> threads = [
    // ── Candidate ──
    EmployerMessageThread(
      id: 'em-1',
      name: 'Sarah Jenkins',
      subtitle: 'Candidate • Flutter Developer',
      lastMessage: 'I confirm the interview on March 7th.',
      time: '09:15',
      unreadCount: 2,
      isPinned: true,
      isOnline: true,
      hasAttachment: false,
      userRole: ChatUserRole.candidate,
      avatarColor: Color(0xFF0A73B7),
    ),
    EmployerMessageThread(
      id: 'em-2',
      name: 'Michael Brown',
      subtitle: 'Candidate • UI/UX Designer',
      lastMessage: 'I just sent my updated portfolio.',
      time: '08:42',
      unreadCount: 1,
      isPinned: false,
      isOnline: true,
      hasAttachment: true,
      userRole: ChatUserRole.candidate,
      avatarColor: Color(0xFF10B981),
    ),
    EmployerMessageThread(
      id: 'em-3',
      name: 'Emily Davis',
      subtitle: 'Candidate • Product Manager',
      lastMessage: 'Could we reschedule the interview to Friday?',
      time: 'Yesterday',
      unreadCount: 0,
      isPinned: false,
      isOnline: false,
      hasAttachment: false,
      userRole: ChatUserRole.candidate,
      avatarColor: Color(0xFFF59E0B),
    ),
    EmployerMessageThread(
      id: 'em-4',
      name: 'David Chen',
      subtitle: 'Candidate • Backend Developer',
      lastMessage: 'Thank you, I will prepare for the test.',
      time: 'Mon',
      unreadCount: 0,
      isPinned: false,
      isOnline: false,
      hasAttachment: false,
      userRole: ChatUserRole.candidate,
      avatarColor: Color(0xFF8B5CF6),
    ),

    // ── Employer (peers / other recruiters) ──
    EmployerMessageThread(
      id: 'em-5',
      name: 'James Wilson',
      subtitle: 'HR Manager • TechSolutions Inc',
      lastMessage: 'Do you have any candidates suitable for a DevOps role?',
      time: '10:30',
      unreadCount: 1,
      isPinned: true,
      isOnline: true,
      hasAttachment: false,
      userRole: ChatUserRole.employer,
      avatarColor: Color(0xFFE8630A),
    ),
    EmployerMessageThread(
      id: 'em-6',
      name: 'Lisa Thompson',
      subtitle: 'Recruiter • CloudNet Corp',
      lastMessage: 'I just shared the candidate shortlist with you.',
      time: 'Tue',
      unreadCount: 0,
      isPinned: false,
      isOnline: false,
      hasAttachment: true,
      userRole: ChatUserRole.employer,
      avatarColor: Color(0xFF6366F1),
    ),

    // ── Admin ──
    EmployerMessageThread(
      id: 'em-7',
      name: 'JobGo Support',
      subtitle: 'Admin • Platform Support',
      lastMessage: 'Your job post "Senior Flutter Dev" has been approved.',
      time: '11:00',
      unreadCount: 1,
      isPinned: false,
      isOnline: true,
      hasAttachment: false,
      userRole: ChatUserRole.admin,
      avatarColor: Color(0xFFEF4444),
    ),
    EmployerMessageThread(
      id: 'em-8',
      name: 'System Admin',
      subtitle: 'Admin • System Management',
      lastMessage: 'Your Premium plan will expire on March 15.',
      time: 'Wed',
      unreadCount: 0,
      isPinned: false,
      isOnline: false,
      hasAttachment: false,
      userRole: ChatUserRole.admin,
      avatarColor: Color(0xFF64748B),
    ),
  ];
}
