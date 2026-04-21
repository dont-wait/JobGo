import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/employer_message_thread.dart';

class MessageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<EmployerMessageThread>> fetchEmployerThreads() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return [];

    final userRow = await _supabase
        .from('users')
        .select('u_id')
        .or('auth_uid.eq.${authUser.id},u_email.eq.${authUser.email}')
        .maybeSingle();

    final userId = _toInt(userRow?['u_id']);
    if (userId == null) return [];

    final messagesResp = await _supabase
        .from('messages')
      .select('m_id, m_sent_at, m_content, m_status, i_id, u_id')
        .eq('u_id', userId)
        .order('m_sent_at', ascending: false);

    final rows = (messagesResp as List)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();

    if (rows.isEmpty) return [];

    final interviewIds = rows
      .map((row) => _toInt(row['i_id']))
      .whereType<int>()
      .toSet()
      .toList();

    final interviewCandidateMap =
      await _loadInterviewCandidates(interviewIds);

    final candidateIds = interviewCandidateMap.values
        .whereType<int>()
        .toSet()
        .toList();

    final candidateMap = await _loadCandidates(candidateIds);

    final Map<int, _ThreadAggregate> aggregates = {};
    for (final row in rows) {
        final interviewId = _toInt(row['i_id']);
        final candidateId = interviewId != null
          ? interviewCandidateMap[interviewId]
          : null;
      if (candidateId == null) continue;

      final sentAt = _toDateTime(row['m_sent_at']);
      final content = _stringValue(row['m_content']);
      final status = _stringValue(row['m_status']);

      final aggregate = aggregates.putIfAbsent(
        candidateId,
        () => _ThreadAggregate(
          lastMessage: content,
          lastSentAt: sentAt,
          unreadCount: 0,
        ),
      );

      if (aggregate.lastSentAt == null ||
          (sentAt != null && sentAt.isAfter(aggregate.lastSentAt!))) {
        aggregate.lastSentAt = sentAt;
        aggregate.lastMessage = content;
      }

      if (status.toLowerCase() == 'unread') {
        aggregate.unreadCount += 1;
      }
    }

    final threadsWithTime = <_ThreadWithTime>[];
    for (final entry in aggregates.entries) {
      final candidate = candidateMap[entry.key];
      final name = _stringValue(candidate?['c_full_name'],
          fallback: 'Candidate');
      final title = _stringValue(candidate?['c_title'], fallback: '');

      threadsWithTime.add(
        _ThreadWithTime(
          thread: EmployerMessageThread(
            id: 'candidate-${entry.key}',
            name: name,
            subtitle: title.isEmpty
                ? 'Candidate'
                : 'Candidate • $title',
            lastMessage: entry.value.lastMessage,
            time: _formatTime(entry.value.lastSentAt),
            unreadCount: entry.value.unreadCount,
            isPinned: false,
            isOnline: false,
            hasAttachment: false,
            userRole: ChatUserRole.candidate,
            avatarColor: _colorFromName(name),
          ),
          lastSentAt: entry.value.lastSentAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }

    threadsWithTime.sort((a, b) => b.lastSentAt.compareTo(a.lastSentAt));
    return threadsWithTime.map((item) => item.thread).toList();
  }

  Future<Map<int, Map<String, dynamic>>> _loadCandidates(
    List<int> candidateIds,
  ) async {
    if (candidateIds.isEmpty) return {};

    final response = await _supabase
        .from('candidates')
        .select('c_id, c_full_name, c_title')
      .inFilter('c_id', candidateIds);

    final map = <int, Map<String, dynamic>>{};
    for (final row in (response as List)) {
      final data = Map<String, dynamic>.from(row);
      final cId = _toInt(data['c_id']);
      if (cId != null) {
        map[cId] = data;
      }
    }

    return map;
  }

  Future<Map<int, int>> _loadInterviewCandidates(
    List<int> interviewIds,
  ) async {
    if (interviewIds.isEmpty) return {};

    final response = await _supabase
        .from('interview_schedule')
        .select('i_id, c_id')
        .inFilter('i_id', interviewIds);

    final map = <int, int>{};
    for (final row in (response as List)) {
      final data = Map<String, dynamic>.from(row);
      final iId = _toInt(data['i_id']);
      final cId = _toInt(data['c_id']);
      if (iId != null && cId != null) {
        map[iId] = cId;
      }
    }

    return map;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
    }
    if (diff.inHours < 24) {
      return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return _weekdayLabel(dateTime.weekday);
    return '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}';
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (weekday < 1 || weekday > 7) return '';
    return labels[weekday - 1];
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  Color _colorFromName(String name) {
    final seed = name.isEmpty ? 1 : name.codeUnits.reduce((a, b) => a + b);
    final random = Random(seed);
    final r = 80 + random.nextInt(140);
    final g = 80 + random.nextInt(140);
    final b = 80 + random.nextInt(140);
    return Color.fromARGB(255, r, g, b);
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}

class _ThreadAggregate {
  DateTime? lastSentAt;
  String lastMessage;
  int unreadCount;

  _ThreadAggregate({
    required this.lastMessage,
    required this.lastSentAt,
    required this.unreadCount,
  });
}

class _ThreadWithTime {
  final EmployerMessageThread thread;
  final DateTime lastSentAt;

  _ThreadWithTime({
    required this.thread,
    required this.lastSentAt,
  });
}
