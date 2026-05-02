import 'dart:developer' as dev;

import 'package:jobgo/data/models/admin_user_model.dart';
import 'package:jobgo/data/models/job_moderation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepository {
  final _supabase = Supabase.instance.client;

  static const Set<String> _allowedSupportStatuses = {
    'open',
    'in_progress',
    'resolved',
    'closed',
  };
  static const Set<String> _allowedSupportPriorities = {
    'low',
    'medium',
    'high',
    'critical',
  };

  bool _isVisibleUser(AdminUserModel user) {
    final status = user.status.trim().toLowerCase();
    return status != 'deleted';
  }

  Future<List<AdminUserModel>> getAllUsers({
    int page = 0,
    int pageSize = 20,
    String? roleFilter,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    final normalizedRole = roleFilter?.trim().toLowerCase();

    dev.log('getAllUsers called with page=$page, pageSize=$pageSize, roleFilter=$roleFilter');

    try {
      if (normalizedRole == 'candidate') {
        dev.log('Preferred path: fetching candidates directly first');
        final candidateUsers = await _fetchCandidateUsers(from: from, to: to);
        if (candidateUsers.isNotEmpty) {
          return candidateUsers;
        }
      }

      if (normalizedRole == 'employer') {
        dev.log('Preferred path: fetching employers directly first');
        final employerUsers = await _fetchEmployerUsers(from: from, to: to);
        if (employerUsers.isNotEmpty) {
          return employerUsers;
        }
      }

      final users = await _fetchUsersFromUsersTable(
        from: from,
        to: to,
        roleFilter: normalizedRole,
      );

      if (users.isNotEmpty) {
        dev.log('Found ${users.length} users from users table');
        return users;
      }

      dev.log('No users found in users table, falling back to role-specific tables');

      if (normalizedRole == 'candidate') {
        dev.log('Fallback: fetching from candidates table after users lookup');
        return await _fetchCandidateUsers(from: from, to: to);
      }

      if (normalizedRole == 'employer') {
        dev.log('Fallback: fetching from employers table after users lookup');
        return await _fetchEmployerUsers(from: from, to: to);
      }

      dev.log('No role filter, fetching both candidates and employers');
      final candidates = await _fetchCandidateUsers(from: from, to: to);
      final employers = await _fetchEmployerUsers(from: from, to: to);
      final merged = [...candidates, ...employers];
      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      dev.log('Merged ${merged.length} users total (${candidates.length} candidates, ${employers.length} employers)');
      return merged;
    } catch (e) {
      dev.log('Error in getAllUsers: $e, attempting legacy fallback');
      try {
        return await _fetchLegacyUsers(
          from: from,
          to: to,
          roleFilter: roleFilter,
        );
      } catch (fallbackError) {
        dev.log('Error fetching users (all methods failed): $fallbackError');
        return [];
      }
    }
  }

  Future<List<AdminUserModel>> _fetchUsersFromUsersTable({
    required int from,
    required int to,
    String? roleFilter,
  }) async {
    dev.log(
      'Fetching users from users table, range: $from-$to, role: $roleFilter',
    );

    try {
      var query = _supabase.from('users').select('*');

      // Filter by role BEFORE range to get correct pagination
      if (roleFilter != null && roleFilter.isNotEmpty) {
        query = query.eq('u_role', roleFilter);
        dev.log('Applying role filter: $roleFilter');
      }

      final response = await query
          .order('u_create_at', ascending: false)
          .range(from, to);

      dev.log('Raw response: $response');
      
      final rows = (response as List).map((json) {
        try {
          return AdminUserModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          dev.log('Error mapping user model: $e, json: $json');
          rethrow;
        }
      }).where(_isVisibleUser).toList();

      dev.log('Users table response length: ${rows.length}');
      if (rows.isNotEmpty) {
        dev.log('First user: id=${rows[0].id}, name=${rows[0].name}, role=${rows[0].role}');
      }
      return rows;
    } catch (e) {
      dev.log('Exception in _fetchUsersFromUsersTable: $e');
      rethrow;
    }
  }

  Future<List<AdminUserModel>> _fetchCandidateUsers({
    required int from,
    required int to,
  }) async {
    try {
      dev.log('Fetching candidates from candidates table, range: $from-$to');
      final response = await _supabase
          .from('candidates')
          .select('*, users(*)')
          .order('c_updated_at', ascending: false)
          .range(from, to);

      final count = (response as List).length;
      dev.log('Candidates response length: $count');

      if (count > 0) {
        return (response as List)
            .map(
              (json) => AdminUserModel.fromJson(json as Map<String, dynamic>),
            )
            .where(_isVisibleUser)
            .toList();
      }

      dev.log(
        'No candidates in candidates table, trying users table with role=candidate',
      );
      final userResponse = await _supabase
          .from('users')
          .select('*')
          .eq('u_role', 'candidate')
          .order('u_create_at', ascending: false)
          .range(from, to);

      dev.log('Users with role=candidate: ${(userResponse as List).length}');
        return (userResponse as List)
          .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
          .where(_isVisibleUser)
          .toList();
    } catch (e) {
      dev.log('Error fetching candidates with join/users fallback: $e');
      try {
        // Some projects do not have FK relation for users(...) join; fetch candidates directly.
        final plainCandidates = await _supabase
            .from('candidates')
            .select('*')
            .order('c_updated_at', ascending: false)
            .range(from, to);

        dev.log('Direct candidates response length: ${(plainCandidates as List).length}');
        return (plainCandidates as List)
            .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
          .where(_isVisibleUser)
            .toList();
      } catch (fallbackError) {
        dev.log('Direct candidates fallback also failed: $fallbackError');
        return [];
      }
    }
  }

  Future<List<AdminUserModel>> _fetchEmployerUsers({
    required int from,
    required int to,
  }) async {
    try {
      dev.log('Fetching employers from employers table, range: $from-$to');
      final response = await _supabase
          .from('employers')
          .select('*, users(*)')
          .order('e_id', ascending: false)
          .range(from, to);

      final count = (response as List).length;
      dev.log('Employers response length: $count');

      if (count > 0) {
        return (response as List)
            .map(
              (json) => AdminUserModel.fromJson(json as Map<String, dynamic>),
            )
            .where(_isVisibleUser)
            .toList();
      }

      dev.log(
        'No employers in employers table, trying users table with role=employer',
      );
      final userResponse = await _supabase
          .from('users')
          .select('*')
          .eq('u_role', 'employer')
          .order('u_create_at', ascending: false)
          .range(from, to);

      dev.log('Users with role=employer: ${(userResponse as List).length}');
        return (userResponse as List)
          .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
          .where(_isVisibleUser)
          .toList();
    } catch (e) {
      dev.log('Error fetching employers with join/users fallback: $e');
      try {
        final plainEmployers = await _supabase
            .from('employers')
            .select('*')
            .order('e_id', ascending: false)
            .range(from, to);

        dev.log('Direct employers response length: ${(plainEmployers as List).length}');
        return (plainEmployers as List)
            .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
          .where(_isVisibleUser)
            .toList();
      } catch (fallbackError) {
        dev.log('Direct employers fallback also failed: $fallbackError');
        return [];
      }
    }
  }

  Future<List<AdminUserModel>> _fetchLegacyUsers({
    required int from,
    required int to,
    String? roleFilter,
  }) async {
    dev.log('_fetchLegacyUsers called with roleFilter=$roleFilter');
    var query = _supabase.from('users').select('*');
    if (roleFilter != null && roleFilter.isNotEmpty) {
      query = query.eq('role', roleFilter);
    }

    final response = await query.order('id', ascending: false).range(from, to);
    dev.log('Legacy users response: ${(response as List).length} records');
    return (response as List)
        .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
      .where(_isVisibleUser)
        .toList();
  }

  /// Debug method to test database connectivity and schema
  Future<Map<String, dynamic>> debugDatabaseSchema() async {
    try {
      dev.log('=== DEBUG: Testing database connectivity ===');
      
      // Test 1: Fetch one record from users table
      final oneUser = await _supabase
          .from('users')
          .select('*')
          .limit(1);
      dev.log('Sample user record: $oneUser');
      
      // Test 2: Check columns in first record
      if ((oneUser as List).isNotEmpty) {
        final firstRecord = oneUser[0] as Map<String, dynamic>;
        final columns = firstRecord.keys.toList();
        dev.log('Available columns in users table: $columns');
      } else {
        dev.log('Users table is empty!');
      }
      
      // Test 3: Try querying with u_role filter
      try {
        final candidatesWithURole = await _supabase
            .from('users')
            .select('*')
            .eq('u_role', 'candidate')
            .limit(5);
        dev.log('u_role filter works, found ${(candidatesWithURole as List).length} candidates');
      } catch (e) {
        dev.log('u_role filter failed: $e, trying legacy "role" filter');
        try {
          final candidatesWithRole = await _supabase
              .from('users')
              .select('*')
              .eq('role', 'candidate')
              .limit(5);
          dev.log('role filter works, found ${(candidatesWithRole as List).length} candidates');
        } catch (e2) {
          dev.log('role filter also failed: $e2');
        }
      }
      
      return {
        'status': 'success',
        'message': 'Database connectivity test passed',
        'sampleRecord': oneUser.isNotEmpty ? oneUser[0] : null,
      };
    } catch (e) {
      dev.log('DEBUG ERROR: $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  Future<bool> blockUser(String userId, String reason) async {
    dev.log('blockUser called for userId=$userId, reason=$reason');

    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    final trimmedUserId = userId.trim();
    final numericId = int.tryParse(trimmedUserId);
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(trimmedUserId);

    int? resolvedUserId;

    try {
      if (numericId != null) {
        final userRow = await _supabase
            .from('users')
            .select('u_id')
            .eq('u_id', numericId)
            .maybeSingle();
        resolvedUserId = toInt(userRow?['u_id']);
      }

      if (resolvedUserId == null && isUuid) {
        final userRow = await _supabase
            .from('users')
            .select('u_id')
            .eq('auth_uid', trimmedUserId)
            .maybeSingle();
        resolvedUserId = toInt(userRow?['u_id']);
      }

      // Fallback: incoming id can be candidate/employer id instead of users.u_id.
      if (resolvedUserId == null && numericId != null) {
        final candidateRow = await _supabase
            .from('candidates')
            .select('u_id')
            .eq('c_id', numericId)
            .maybeSingle();
        resolvedUserId = toInt(candidateRow?['u_id']);
      }

      if (resolvedUserId == null && numericId != null) {
        final employerRow = await _supabase
            .from('employers')
            .select('u_id')
            .eq('e_id', numericId)
            .maybeSingle();
        resolvedUserId = toInt(employerRow?['u_id']);
      }
    } catch (e) {
      dev.log('blockUser resolve failed: $e');
    }

    if (resolvedUserId == null) {
      dev.log('blockUser failed: no user row found for $trimmedUserId');
      return false;
    }

    try {
      await _supabase
          .from('users')
          .update({
            'u_status': 'blocked',
          })
          .eq('u_id', resolvedUserId);
      dev.log('blockUser success with u_id=$resolvedUserId');
      return true;
    } catch (e) {
      dev.log('Error blocking user: $e');
      return false;
    }
  }

  Future<bool> unblockUser(String userId) async {
    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    final trimmedUserId = userId.trim();
    final numericId = int.tryParse(trimmedUserId);
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(trimmedUserId);

    int? resolvedUserId;

    try {
      if (numericId != null) {
        final userRow = await _supabase
            .from('users')
            .select('u_id')
            .eq('u_id', numericId)
            .maybeSingle();
        resolvedUserId = toInt(userRow?['u_id']);
      }

      if (resolvedUserId == null && isUuid) {
        final userRow = await _supabase
            .from('users')
            .select('u_id')
            .eq('auth_uid', trimmedUserId)
            .maybeSingle();
        resolvedUserId = toInt(userRow?['u_id']);
      }

      // Fallback: incoming id can be candidate/employer id instead of users.u_id.
      if (resolvedUserId == null && numericId != null) {
        final candidateRow = await _supabase
            .from('candidates')
            .select('u_id')
            .eq('c_id', numericId)
            .maybeSingle();
        resolvedUserId = toInt(candidateRow?['u_id']);
      }

      if (resolvedUserId == null && numericId != null) {
        final employerRow = await _supabase
            .from('employers')
            .select('u_id')
            .eq('e_id', numericId)
            .maybeSingle();
        resolvedUserId = toInt(employerRow?['u_id']);
      }
    } catch (e) {
      dev.log('unblockUser resolve failed: $e');
    }

    if (resolvedUserId == null) {
      dev.log('unblockUser failed: no user row found for $trimmedUserId');
      return false;
    }

    try {
      await _supabase
          .from('users')
          .update({
            'u_status': 'active',
          })
          .eq('u_id', resolvedUserId);
      return true;
    } catch (e) {
      dev.log('Error unblocking user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    final trimmedUserId = userId.trim();

    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    final numericId = int.tryParse(trimmedUserId);
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(trimmedUserId);

    int? resolvedUserId;
    bool foundAnyRow = false;

    // Resolve the canonical users.u_id first (schema is FK-based on u_id).
    try {
      if (numericId != null) {
        final userRow = await _supabase
            .from('users')
            .select('u_id')
            .eq('u_id', numericId)
            .maybeSingle();
        if (userRow != null) {
          resolvedUserId = toInt(userRow['u_id']);
          foundAnyRow = true;
        }
      }

      if (resolvedUserId == null && isUuid) {
        final userRow = await _supabase
            .from('users')
            .select('u_id')
            .eq('auth_uid', trimmedUserId)
            .maybeSingle();
        if (userRow != null) {
          resolvedUserId = toInt(userRow['u_id']);
          foundAnyRow = true;
        }
      }
    } catch (e) {
      dev.log('Resolve users.u_id failed for $trimmedUserId: $e');
    }

    // If the passed id is numeric and no users row was found yet, treat it as u_id candidate.
    resolvedUserId ??= numericId;

    // If still unresolved, numeric id may be c_id/e_id; map back to u_id.
    if (resolvedUserId == null && numericId != null) {
      try {
        final candidateRow = await _supabase
            .from('candidates')
            .select('u_id')
            .eq('c_id', numericId)
            .maybeSingle();
        final candidateUid = toInt(candidateRow?['u_id']);
        if (candidateUid != null) {
          resolvedUserId = candidateUid;
          foundAnyRow = true;
        }
      } catch (_) {}

      if (resolvedUserId == null) {
        try {
          final employerRow = await _supabase
              .from('employers')
              .select('u_id')
              .eq('e_id', numericId)
              .maybeSingle();
          final employerUid = toInt(employerRow?['u_id']);
          if (employerUid != null) {
            resolvedUserId = employerUid;
            foundAnyRow = true;
          }
        } catch (_) {}
      }
    }

    // Prefer soft-delete when status columns exist.
    if (resolvedUserId != null) {
      try {
        final userRows = await _supabase
            .from('users')
            .select('u_id')
            .eq('u_id', resolvedUserId)
            .limit(1);
        if ((userRows as List).isNotEmpty) {
          foundAnyRow = true;
          await _supabase.from('users').update({
            'u_status': 'deleted',
            'u_deleted_at': DateTime.now().toIso8601String(),
          }).eq('u_id', resolvedUserId);
          return true;
        }
      } catch (e) {
        var anyDeleted = false;

        // Any soft-delete failure should still try hard-delete path.
        try {
          final candidateRows = await _supabase
              .from('candidates')
              .select('c_id')
              .eq('u_id', resolvedUserId)
              .limit(1);
          if ((candidateRows as List).isNotEmpty) {
            await _supabase.from('candidates').delete().eq('u_id', resolvedUserId);
            anyDeleted = true;
          }
        } catch (childErr) {
          dev.log('Hard delete candidates failed (u_id=$resolvedUserId): $childErr');
        }

        try {
          final employerRows = await _supabase
              .from('employers')
              .select('e_id')
              .eq('u_id', resolvedUserId)
              .limit(1);
          if ((employerRows as List).isNotEmpty) {
            await _supabase.from('employers').delete().eq('u_id', resolvedUserId);
            anyDeleted = true;
          }
        } catch (childErr) {
          dev.log('Hard delete employers failed (u_id=$resolvedUserId): $childErr');
        }

        try {
          await _supabase.from('users').delete().eq('u_id', resolvedUserId);
          return true;
        } catch (deleteErr) {
          dev.log('Hard delete users failed (u_id=$resolvedUserId): $deleteErr');
          if (anyDeleted) {
            return true;
          }

          // Final fallback where hard delete is blocked by FK constraints.
          try {
            await _supabase.from('users').update({
              'u_role': 'deleted',
              'u_update_at': DateTime.now().toIso8601String(),
            }).eq('u_id', resolvedUserId);
            return true;
          } catch (roleFallbackErr) {
            dev.log('Role fallback delete failed (u_id=$resolvedUserId): $roleFallbackErr');
          }
        }

        dev.log('Soft delete users by u_id failed (u_id=$resolvedUserId): $e');
      }
    }

    dev.log('Delete user failed: id=$trimmedUserId, resolvedUserId=$resolvedUserId, foundAnyRow=$foundAnyRow');
    return false;
  }

  Future<List<AdminUserModel>> getDeletedUsers({
    int page = 0,
    int pageSize = 20,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    try {
      // Tìm các user có trạng thái là deleted
      final response = await _supabase
          .from('users')
          .select('*')
          .or('u_status.eq.deleted,u_role.eq.deleted')
          .order('u_create_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      dev.log('Error fetching deleted users: $e');
      return [];
    }
  }

  Future<bool> restoreUser(String userId) async {
    final trimmedUserId = userId.trim();
    final numericId = int.tryParse(trimmedUserId);
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(trimmedUserId);

    int? resolvedUserId;
    try {
      if (numericId != null) {
        final userRow = await _supabase.from('users').select('u_id').eq('u_id', numericId).maybeSingle();
        if (userRow != null) resolvedUserId = int.tryParse(userRow['u_id'].toString());
      }
      if (resolvedUserId == null && isUuid) {
        final userRow = await _supabase.from('users').select('u_id').eq('auth_uid', trimmedUserId).maybeSingle();
        if (userRow != null) resolvedUserId = int.tryParse(userRow['u_id'].toString());
      }
    } catch (_) {}

    resolvedUserId ??= numericId;

    if (resolvedUserId != null) {
      try {
        await _supabase.from('users').update({
          'u_status': 'active', // Trả về trạng thái hoạt động bình thường
          'u_deleted_at': null,
        }).eq('u_id', resolvedUserId);
        return true;
      } catch (e) {
        dev.log('Restore user failed: $e');
      }
    }
    return false;
  }

  Future<bool> hardDeleteUser(String userId) async {
    final trimmedUserId = userId.trim();
    final numericId = int.tryParse(trimmedUserId);
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(trimmedUserId);

    int? resolvedUserId;
    try {
      if (numericId != null) {
        final userRow = await _supabase.from('users').select('u_id').eq('u_id', numericId).maybeSingle();
        if (userRow != null) resolvedUserId = int.tryParse(userRow['u_id'].toString());
      }
      if (resolvedUserId == null && isUuid) {
        final userRow = await _supabase.from('users').select('u_id').eq('auth_uid', trimmedUserId).maybeSingle();
        if (userRow != null) resolvedUserId = int.tryParse(userRow['u_id'].toString());
      }
    } catch (_) {}

    resolvedUserId ??= numericId;

    if (resolvedUserId != null) {
      // Cố gắng xóa các dữ liệu liên quan trước (Candidates, Employers) để tránh lỗi Khóa ngoại (Foreign Key)
      try {
        await _supabase.from('candidates').delete().eq('u_id', resolvedUserId);
      } catch (_) {}
      
      try {
        await _supabase.from('employers').delete().eq('u_id', resolvedUserId);
      } catch (_) {}

      // Cuối cùng xóa vĩnh viễn khỏi bảng users
      try {
        await _supabase.from('users').delete().eq('u_id', resolvedUserId);
        
        // Thử xóa luôn cả trong bảng auth.users nếu có quyền admin
        if (isUuid) {
          try {
             await _supabase.auth.admin.deleteUser(trimmedUserId);
          } catch (_) {}
        }
        return true;
      } catch (e) {
        dev.log('Hard delete user failed: $e');
      }
    }
    return false;
  }

  Future<List<JobModerationItem>> getPendingJobs({
    int page = 0,
    int pageSize = 20,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    try {
      final response = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .eq('j_moderation_status', 'pending')
          .order('j_create_at', ascending: false)
          .range(from, to);

      final items = (response as List)
          .map((json) => _mapJobModeration(json as Map<String, dynamic>))
          .toList();

      if (items.isNotEmpty) {
        return items;
      }

      // Fallback: fetch latest and filter client-side.
      final allJobs = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .order('j_create_at', ascending: false)
          .range(from, to);

      return (allJobs as List)
          .map((json) => _mapJobModeration(json as Map<String, dynamic>))
          .where((job) => job.status == 'pending')
          .toList();
    } catch (e) {
      try {
        final response = await _supabase
            .from('jobs')
            .select('*, employers(*)')
            .eq('j_status', 'pending')
            .order('j_create_at', ascending: false)
            .range(from, to);

        final items = (response as List)
            .map((json) => _mapJobModeration(json as Map<String, dynamic>))
            .toList();

        if (items.isNotEmpty) {
          return items;
        }

        final allJobs = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .order('j_create_at', ascending: false)
          .range(from, to);

        return (allJobs as List)
            .map((json) => _mapJobModeration(json as Map<String, dynamic>))
            .where((job) => job.status == 'pending')
            .toList();
      } catch (fallbackError) {
        dev.log('Error fetching pending jobs: $fallbackError');
        return [];
      }
    }
  }

  Future<List<JobModerationItem>> getModeratedJobs({
    int page = 0,
    int pageSize = 20,
    String? status,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    try {
      var query = _supabase.from('jobs').select('*, employers(*)');
      if (status != null && status.isNotEmpty) {
        final normalized = status.trim().toLowerCase();
        if (normalized == 'approved') {
          query = query.or(
            'j_moderation_status.eq.approved,j_status.eq.approved,j_status.eq.active',
          );
        } else if (normalized == 'rejected') {
          query = query.or(
            'j_moderation_status.eq.rejected,j_status.eq.rejected,j_status.eq.inactive',
          );
        } else if (normalized == 'expired') {
          query = query.or(
            'j_status.eq.expired,j_status.eq.closed',
          );
        }
      } else {
        query = query.neq('j_moderation_status', 'pending');
      }

      final response = await query
          .order('j_create_at', ascending: false)
          .range(from, to);

      final items = (response as List)
          .map((json) => _mapJobModeration(json as Map<String, dynamic>))
          .toList();

      if (items.isEmpty) {
        // Fallback for schema/policy mismatch: get latest jobs and filter in code.
        final allJobs = await _supabase
            .from('jobs')
            .select('*, employers(*)')
            .order('j_create_at', ascending: false)
            .range(from, to);

        final mapped = (allJobs as List)
            .map((json) => _mapJobModeration(json as Map<String, dynamic>))
            .toList();

        if (status == null || status.isEmpty) {
          return mapped.where((item) => item.status != 'pending').toList();
        }

        final normalized = status.trim().toLowerCase();
        if (normalized == 'expired') {
          return mapped.where((item) => item.status == 'expired' || item.status == 'closed').toList();
        }
        return mapped.where((item) => item.status == normalized).toList();
      }

      // Final guard to avoid pending items leaking into approved/rejected tabs.
      if (status == null || status.isEmpty) {
        return items.where((item) => item.status != 'pending').toList();
      }
      final normalized = status.trim().toLowerCase();
      if (normalized == 'expired') {
        return items.where((item) => item.status == 'expired' || item.status == 'closed').toList();
      }
      return items.where((item) => item.status == normalized).toList();
    } catch (e) {
      dev.log('Error fetching moderated jobs: $e');
      return [];
    }
  }

  Future<bool> approveJob(String jobId) async {
    final numericId = int.tryParse(jobId);

    Future<bool> updateCanonicalStatus(dynamic targetId) async {
      try {
        final rows = await _supabase
            .from('jobs')
            .update({'j_moderation_status': 'approved', 'j_status': 'active'})
            .eq('j_id', targetId)
            .select('j_id');
        return (rows as List).isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    Future<bool> updateLegacyStatus(dynamic targetId) async {
      try {
        final rows = await _supabase
            .from('jobs')
            .update({'status': 'approved'})
            .eq('j_id', targetId)
            .select('j_id');
        return (rows as List).isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    Future<void> updateApproveMetadataBestEffort(dynamic targetId) async {
      final now = DateTime.now().toIso8601String();
      final adminUid = _supabase.auth.currentUser?.id;

      try {
        await _supabase
            .from('jobs')
            .update({'j_approved_at': now, 'j_approved_by': adminUid})
            .eq('j_id', targetId);
      } catch (_) {}

      try {
        await _supabase
            .from('jobs')
            .update({'approved_at': now, 'approved_by': adminUid})
            .eq('j_id', targetId);
      } catch (_) {}
    }

    final targets = <dynamic>[jobId, if (numericId != null) numericId];
    for (final target in targets) {
      final ok = await updateCanonicalStatus(target) ||
          await updateLegacyStatus(target);
      if (ok) {
        await updateApproveMetadataBestEffort(target);
        return true;
      }
    }

    dev.log('Error approving job: no rows updated for jobId=$jobId');
    return false;
  }

  Future<bool> rejectJob(
    String jobId,
    List<String> rejectionReasons,
    String? note,
  ) async {
    final numericId = int.tryParse(jobId);

    Future<bool> updateCanonicalStatus(dynamic targetId) async {
      try {
        final rows = await _supabase
            .from('jobs')
            .update({'j_moderation_status': 'rejected', 'j_status': 'inactive'})
            .eq('j_id', targetId)
            .select('j_id');
        return (rows as List).isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    Future<bool> updateLegacyStatus(dynamic targetId) async {
      try {
        final rows = await _supabase
            .from('jobs')
            .update({'status': 'rejected'})
            .eq('j_id', targetId)
            .select('j_id');
        return (rows as List).isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    Future<void> updateRejectMetadataBestEffort(dynamic targetId) async {
      final now = DateTime.now().toIso8601String();
      final adminUid = _supabase.auth.currentUser?.id;
      final reasonsText = rejectionReasons.join(',');

      try {
        await _supabase
            .from('jobs')
            .update({
              'j_rejection_reasons': reasonsText,
              'j_rejection_note': note,
              'j_rejected_at': now,
              'j_rejected_by': adminUid,
            })
            .eq('j_id', targetId);
      } catch (_) {}

      try {
        await _supabase
            .from('jobs')
            .update({
              'rejection_reasons': reasonsText,
              'rejection_note': note,
              'rejected_at': now,
              'rejected_by': adminUid,
            })
            .eq('j_id', targetId);
      } catch (_) {}
    }

    final targets = <dynamic>[jobId, if (numericId != null) numericId];
    for (final target in targets) {
      final ok = await updateCanonicalStatus(target) ||
          await updateLegacyStatus(target);
      if (ok) {
        await updateRejectMetadataBestEffort(target);
        return true;
      }
    }

    dev.log('Error rejecting job: no rows updated for jobId=$jobId');
    return false;
  }

  Future<bool> deleteJob(String jobId) async {
    final numericId = int.tryParse(jobId);

    Future<bool> markJobAsRemoved(dynamic targetId) async {
      final now = DateTime.now().toIso8601String();
      final adminUid = _supabase.auth.currentUser?.id;

      try {
        final rows = await _supabase
            .from('jobs')
            .update({'j_moderation_status': 'rejected', 'j_status': 'inactive'})
            .eq('j_id', targetId)
            .select('j_id');
        final ok = (rows as List).isNotEmpty;
        if (!ok) return false;

        try {
          await _supabase
              .from('jobs')
              .update({
                'j_rejection_note': 'Removed by admin',
                'j_rejected_at': now,
                'j_rejected_by': adminUid,
              })
              .eq('j_id', targetId);
        } catch (_) {}

        return true;
      } catch (_) {
        try {
          final rows = await _supabase
              .from('jobs')
              .update({'status': 'rejected'})
              .eq('j_id', targetId)
              .select('j_id');
          final ok = (rows as List).isNotEmpty;
          if (!ok) return false;

          try {
            await _supabase
                .from('jobs')
                .update({
                  'rejection_note': 'Removed by admin',
                  'rejected_at': now,
                  'rejected_by': adminUid,
                })
                .eq('j_id', targetId);
          } catch (_) {}

          return true;
        } catch (e) {
          dev.log('Error marking job as removed: $e');
          return false;
        }
      }
    }

    final targets = <dynamic>[jobId, if (numericId != null) numericId];
    for (final target in targets) {
      final ok = await markJobAsRemoved(target);
      if (ok) {
        return true;
      }
    }

    dev.log('Remove-from-approved failed for jobId=$jobId');
    return false;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersResp = await _supabase.from('users').select('u_id');
      final pendingJobsResp = await _supabase
          .from('jobs')
          .select('j_id')
          .eq('j_moderation_status', 'pending');
      final activeJobsResp = await _supabase
          .from('jobs')
          .select('j_id')
          .eq('j_moderation_status', 'approved');
      final employersResp = await _supabase
          .from('users')
          .select('u_id')
          .eq('u_role', 'employer');

      return {
        'totalUsers': usersResp.length,
        'pendingJobs': pendingJobsResp.length,
        'activeJobs': activeJobsResp.length,
        'totalEmployers': employersResp.length,
      };
    } catch (e) {
      try {
        final usersResp = await _supabase.from('users').select('id');
        final pendingJobsResp = await _supabase
            .from('jobs')
            .select('j_id')
            .eq('status', 'pending');
        final activeJobsResp = await _supabase
            .from('jobs')
            .select('j_id')
            .eq('status', 'approved');
        final employersResp = await _supabase
            .from('users')
            .select('id')
            .eq('role', 'employer');

        return {
          'totalUsers': usersResp.length,
          'pendingJobs': pendingJobsResp.length,
          'activeJobs': activeJobsResp.length,
          'totalEmployers': employersResp.length,
        };
      } catch (fallbackError) {
        dev.log('Error fetching dashboard stats: $fallbackError');
        return {
          'totalUsers': 0,
          'pendingJobs': 0,
          'activeJobs': 0,
          'totalEmployers': 0,
        };
      }
    }
  }

  Future<List<Map<String, dynamic>>> getReportedIssues({
    int page = 0,
    int pageSize = 20,
    String? status,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final normalizedStatus = status?.trim().toLowerCase();

    try {
      var query = _supabase.from('support_issues').select('*');
      if (normalizedStatus != null &&
          normalizedStatus.isNotEmpty &&
          normalizedStatus != 'all') {
        query = query.eq('si_status', normalizedStatus);
      }

      final response = await query
          .order('si_created_at', ascending: false)
          .range(from, to);

        final normalized = (response as List)
          .map((raw) => _normalizeIssue(raw as Map<String, dynamic>))
          .toList();

        if (normalized.isNotEmpty) {
        return normalized;
        }

        // If support_issues exists but has no data, still try legacy table.
        final legacyResponse = await _supabase
          .from('support_tickets')
          .select('*')
          .order('created_at', ascending: false)
          .range(from, to);

        return (legacyResponse as List)
          .map((raw) => _normalizeIssue(raw as Map<String, dynamic>))
          .toList();
    } catch (e) {
      try {
        var query = _supabase.from('support_tickets').select('*');
        if (normalizedStatus != null &&
            normalizedStatus.isNotEmpty &&
            normalizedStatus != 'all') {
          query = query.eq('status', normalizedStatus);
        }

        final response = await query
            .order('created_at', ascending: false)
            .range(from, to);

        return (response as List)
            .map((raw) => _normalizeIssue(raw as Map<String, dynamic>))
            .toList();
      } catch (fallbackError) {
        // Final fallback: derive issue-like items from applications.
        try {
          final apps = await _supabase
              .from('applications')
              .select('*, jobs(j_title), candidates(c_full_name)')
              .order('a_updated_at', ascending: false)
              .range(from, to);

          final mapped = (apps as List)
              .map((raw) => _normalizeApplicationIssue(raw as Map<String, dynamic>))
              .toList();

          if (normalizedStatus != null &&
              normalizedStatus.isNotEmpty &&
              normalizedStatus != 'all') {
            return mapped
                .where((item) =>
                    (item['status']?.toString().toLowerCase() ?? '') ==
                    normalizedStatus)
                .toList();
          }

          return mapped;
        } catch (appsFallbackError) {
          dev.log('Error fetching reported issues: $appsFallbackError');
          return [];
        }
      }
    }
  }

  Future<int> getUnresolvedTicketsCount() async {
    try {
      final response = await _supabase
          .from('support_issues')
          .select('si_id, si_status');

      return (response as List).where((item) {
        final status =
            (item as Map<String, dynamic>)['si_status']
                ?.toString()
                .toLowerCase() ??
            '';
        return status != 'resolved' && status != 'closed';
      }).length;
    } catch (e) {
      try {
        final response = await _supabase
            .from('support_tickets')
            .select('id')
            .eq('status', 'open');
        return response.length;
      } catch (fallbackError) {
        try {
          final apps = await _supabase
              .from('applications')
              .select('a_id, a_status');
          return (apps as List).where((item) {
            final status = (item as Map<String, dynamic>)['a_status']
                    ?.toString()
                    .toLowerCase() ??
                '';
            return status == 'pending' || status == 'reviewed';
          }).length;
        } catch (appsFallbackError) {
          dev.log('Error getting unresolved count: $appsFallbackError');
          return 0;
        }
      }
    }
  }

  Future<bool> updateSupportIssueStatus({
    required String ticketId,
    required String status,
    String? adminNote,
    String? priority,
  }) async {
    final normalizedStatus = status.trim().toLowerCase();
    if (!_allowedSupportStatuses.contains(normalizedStatus)) {
      dev.log('Invalid support status: $status');
      return false;
    }

    final normalizedPriority = priority?.trim().toLowerCase();
    if (normalizedPriority != null &&
        !_allowedSupportPriorities.contains(normalizedPriority)) {
      dev.log('Invalid support priority: $priority');
      return false;
    }

    try {
      await _supabase
          .from('support_issues')
          .update({
            'si_status': normalizedStatus,
            if (adminNote != null) 'si_admin_notes': adminNote,
            if (normalizedPriority != null) 'si_priority': normalizedPriority,
            'si_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('si_id', ticketId);
      return true;
    } catch (e) {
      try {
        await _supabase
            .from('support_tickets')
            .update({
              'status': normalizedStatus,
              if (adminNote != null) 'resolution': adminNote,
              if (normalizedPriority != null) 'priority': normalizedPriority,
              if (normalizedStatus == 'resolved')
                'resolved_at': DateTime.now().toIso8601String(),
            })
            .eq('id', ticketId);
        return true;
      } catch (fallbackError) {
        // Final fallback: ticket can be derived from applications table.
        final appId = int.tryParse(ticketId.replaceFirst('app-', ''));
        if (appId == null) {
          dev.log('Error updating issue status: $fallbackError');
          return false;
        }

        String appStatus;
        switch (normalizedStatus) {
          case 'open':
            appStatus = 'pending';
            break;
          case 'in_progress':
            appStatus = 'reviewed';
            break;
          case 'closed':
            appStatus = 'rejected';
            break;
          default:
            appStatus = 'accepted';
        }

        try {
          await _supabase
              .from('applications')
              .update({
                'a_status': appStatus,
                if (adminNote != null) 'a_internal_notes': adminNote,
                'a_updated_at': DateTime.now().toIso8601String(),
              })
              .eq('a_id', appId);
          return true;
        } catch (appsFallbackError) {
          dev.log('Error updating issue status: $appsFallbackError');
          return false;
        }
      }
    }
  }

  Future<bool> resolveTicket(String ticketId, String resolution) {
    return updateSupportIssueStatus(
      ticketId: ticketId,
      status: 'resolved',
      adminNote: resolution,
    );
  }

  JobModerationItem _mapJobModeration(Map<String, dynamic> json) {
    final reasons =
        (json['j_rejection_reasons'] as String?)
            ?.split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];

    String rawStatus = 'pending';
    final jStat = (json['j_status'] ?? json['status'])?.toString().toLowerCase();
    final mStat = json['j_moderation_status']?.toString().toLowerCase();

    if (jStat == 'expired' || jStat == 'closed') {
      rawStatus = jStat!;
    } else {
      rawStatus = mStat ?? jStat ?? 'pending';
    }

    final normalizedStatus = rawStatus == 'active'
      ? 'approved'
      : rawStatus == 'inactive'
      ? 'rejected'
      : rawStatus;

    return JobModerationItem.fromJson({
      ...json,
      'id': json['j_id'] ?? json['id'],
      'title': json['j_title'] ?? json['title'],
      'company':
          (json['employers'] as Map<String, dynamic>?)?['company_name'] ??
          json['company'] ??
          '',
      'location': json['j_location'] ?? json['location'] ?? '',
      'salaryRange': json['j_salary_range'] ?? json['salaryRange'] ?? '',
      'postedDate': json['j_create_at'] ?? json['postedDate'],
      'status': normalizedStatus,
      'description': json['j_description'] ?? json['description'],
      'rejectionReasons': reasons,
    });
  }

  Map<String, dynamic> _normalizeIssue(Map<String, dynamic> raw) {
    final id = (raw['si_id'] ?? raw['id'] ?? '').toString();
    final status = (raw['si_status'] ?? raw['status'] ?? 'open')
        .toString()
        .toLowerCase();
    final priority = (raw['si_priority'] ?? raw['priority'] ?? 'medium')
        .toString();

    return {
      'id': id,
      'status': status,
      'priority': priority,
      'category': (raw['si_category'] ?? raw['category'] ?? 'other').toString(),
      'title':
          (raw['si_title'] ?? raw['title'] ?? raw['subject'] ?? 'Issue #$id')
              .toString(),
      'description':
          (raw['si_description'] ?? raw['description'] ?? raw['message'] ?? '')
              .toString(),
      'adminNote': (raw['si_admin_notes'] ?? raw['resolution'] ?? '')
          .toString(),
      'createdAt': (raw['si_created_at'] ?? raw['created_at'] ?? '').toString(),
    };
  }

  Map<String, dynamic> _normalizeApplicationIssue(Map<String, dynamic> raw) {
    final appId = (raw['a_id'] ?? '').toString();
    final appStatus = (raw['a_status'] ?? 'pending').toString().toLowerCase();
    final status = appStatus == 'pending'
        ? 'open'
        : appStatus == 'reviewed'
        ? 'in_progress'
        : appStatus == 'accepted' || appStatus == 'rejected'
        ? 'resolved'
        : 'open';

    final jobTitle = ((raw['jobs'] as Map<String, dynamic>?)?['j_title'] ??
            'Application #$appId')
        .toString();
    final candidateName =
        ((raw['candidates'] as Map<String, dynamic>?)?['c_full_name'] ??
                'Unknown Candidate')
            .toString();

    return {
      'id': 'app-$appId',
      'status': status,
      'priority': 'medium',
      'category': 'application',
      'title': 'Application: $jobTitle',
      'description':
          'Candidate: $candidateName\n${(raw['a_cover_letter'] ?? '').toString()}',
      'adminNote': (raw['a_internal_notes'] ?? '').toString(),
      'createdAt': (raw['a_applied_at'] ?? '').toString(),
    };
  }
}
