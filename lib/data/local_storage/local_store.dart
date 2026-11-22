import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/student_profile.dart';
import '../models/team.dart';
import '../models/team_request.dart';
import '../models/team_task.dart';
import '../models/chat_message.dart';
import '../models/filter_preset.dart';
import '../models/user_account.dart';
import '../seed/seed_data.dart';
import '../../features/auth/services/auth_service.dart';

class LocalStore {
  static const String _appBoxName = 'teamup_storage_box';

  static const String _keyIsSeeded = 'key_is_seeded';
  static const String _keyActiveSessionUserId = 'key_active_session_user_id';
  static const String _keyAccounts = 'key_accounts';
  static const String _keyStudents = 'key_students';
  static const String _keyThemeMode = 'key_theme_mode';

  // Legacy fallback keys
  static const String _keyLegacyCurrentUser = 'key_current_user';
  static const String _keyLegacyTeam = 'key_team';
  static const String _keyLegacyRequests = 'key_requests';
  static const String _keyLegacyTasks = 'key_tasks';
  static const String _keyLegacyChatMessages = 'key_chat_messages';
  static const String _keyLegacyPresets = 'key_presets';

  static late Box _box;

  /// Initialize Hive, persistent accounts, and seed demo dataset
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_appBoxName);

    // Ensure demo account always exists
    await _ensureDemoAccount();

    final bool isAlreadySeeded =
        _box.get(_keyIsSeeded, defaultValue: false) as bool;
    if (!isAlreadySeeded) {
      debugPrint('[LocalStore] Initializing competition seed dataset...');
      await _seedInitialData();
    } else {
      debugPrint('[LocalStore] Persistent storage loaded from Hive.');
    }
  }

  /// Ensure competition demo account exists (demo@teamup.app / TeamUp123)
  static Future<void> _ensureDemoAccount() async {
    final existingDemo = findAccountByEmail(AppConstants.demoEmail);
    if (existingDemo == null) {
      const demoId = 'user_current';
      final salt = 'visiospark_fa26';
      final passwordHash = AuthService.hashPassword(AppConstants.demoPassword, salt);
      final demoAccount = UserAccount(
        id: demoId,
        name: 'Zayan Ahmed',
        email: AppConstants.demoEmail,
        passwordHash: passwordHash,
        salt: salt,
        createdAt: DateTime.now(),
      );
      await saveAccount(demoAccount);
    }
  }

  static Future<void> _seedInitialData() async {
    // Current User profile for demo
    await saveCurrentUser(SeedData.defaultCurrentUser);

    // Student Profiles (ensure eligible 4-8 only)
    await saveStudents(SeedData.seedStudents);

    // Team
    await saveTeam(SeedData.defaultTeam);

    // Requests
    await saveRequests(SeedData.seedRequests);

    // Tasks
    await saveTasks(SeedData.seedTasks);

    // Messages
    await saveChatMessages(SeedData.seedMessages);

    // Filter Presets
    await saveFilterPresets(SeedData.seedPresets);

    await _box.put(_keyIsSeeded, true);
  }

  /// Reset to clean demo state
  static Future<void> resetToSeedData() async {
    await _box.clear();
    await _ensureDemoAccount();
    await _seedInitialData();
  }

  // Session Management
  static String? getActiveSessionUserId() {
    return _box.get(_keyActiveSessionUserId) as String?;
  }

  static Future<void> setActiveSessionUserId(String? userId) async {
    if (userId == null) {
      await _box.delete(_keyActiveSessionUserId);
    } else {
      await _box.put(_keyActiveSessionUserId, userId);
    }
  }

  // Multi-Account Storage
  static List<UserAccount> getAllAccounts() {
    final raw = _box.get(_keyAccounts);
    if (raw != null) {
      try {
        final List<dynamic> list = json.decode(raw as String);
        return list
            .map((item) => UserAccount.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStore] Error parsing accounts: $e');
      }
    }
    return [];
  }

  static Future<void> saveAccount(UserAccount account) async {
    final accounts = getAllAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id || a.email == account.email);
    if (index != -1) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    final encoded = json.encode(accounts.map((a) => a.toMap()).toList());
    await _box.put(_keyAccounts, encoded);
  }

  static UserAccount? findAccountByEmail(String email) {
    final accounts = getAllAccounts();
    try {
      return accounts.firstWhere((a) => a.email.toLowerCase() == email.toLowerCase().trim());
    } catch (_) {
      return null;
    }
  }

  static UserAccount? findAccountById(String id) {
    final accounts = getAllAccounts();
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // Per-User Key Helpers
  static String _userKey(String suffix) {
    final currentUserId = getActiveSessionUserId() ?? 'user_current';
    return 'key_${currentUserId}_$suffix';
  }

  // Current User Profile (Isolated per account)
  static StudentProfile getCurrentUser() {
    final key = _userKey('profile');
    final raw = _box.get(key) ?? _box.get(_keyLegacyCurrentUser);
    if (raw != null) {
      try {
        return StudentProfile.fromJson(raw as String);
      } catch (e) {
        debugPrint('[LocalStore] Error parsing user profile: $e');
      }
    }
    return SeedData.defaultCurrentUser;
  }

  static Future<void> saveCurrentUser(StudentProfile user) async {
    final key = _userKey('profile');
    await _box.put(key, user.toJson());
    // Also update legacy if demo
    if (getActiveSessionUserId() == 'user_current' || getActiveSessionUserId() == null) {
      await _box.put(_keyLegacyCurrentUser, user.toJson());
    }
  }

  // Students Directory (Filters out current user and restricts to eligible semesters 4-8)
  static List<StudentProfile> getStudents() {
    final raw = _box.get(_keyStudents);
    List<StudentProfile> list = [];
    if (raw != null) {
      try {
        final List<dynamic> rawList = json.decode(raw as String);
        list = rawList
            .map((item) => StudentProfile.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStore] Error parsing students: $e');
        list = SeedData.seedStudents;
      }
    } else {
      list = SeedData.seedStudents;
    }

    final currentId = getCurrentUser().id;
    return list
        .where((s) => s.id != currentId && s.semester >= AppConstants.minEligibleSemester && s.semester <= AppConstants.maxEligibleSemester)
        .toList();
  }

  static Future<void> saveStudents(List<StudentProfile> students) async {
    final encoded = json.encode(students.map((s) => s.toMap()).toList());
    await _box.put(_keyStudents, encoded);
  }

  // Team (Isolated per account)
  static Team? getTeam() {
    final key = _userKey('team');
    final raw = _box.get(key);
    if (raw != null) {
      try {
        return Team.fromJson(raw as String);
      } catch (e) {
        debugPrint('[LocalStore] Error parsing team: $e');
      }
    }
    // Fallback for demo user
    if (getActiveSessionUserId() == 'user_current' || getActiveSessionUserId() == null) {
      final leg = _box.get(_keyLegacyTeam);
      if (leg != null) {
        try {
          return Team.fromJson(leg as String);
        } catch (_) {}
      }
      return SeedData.defaultTeam;
    }
    return null;
  }

  static Future<void> saveTeam(Team? team) async {
    final key = _userKey('team');
    if (team == null) {
      await _box.delete(key);
      if (getActiveSessionUserId() == 'user_current') await _box.delete(_keyLegacyTeam);
    } else {
      await _box.put(key, team.toJson());
      if (getActiveSessionUserId() == 'user_current') await _box.put(_keyLegacyTeam, team.toJson());
    }
  }

  // Requests (Isolated per account)
  static List<TeamRequest> getRequests() {
    final key = _userKey('requests');
    final raw = _box.get(key);
    if (raw != null) {
      try {
        final List<dynamic> list = json.decode(raw as String);
        return list
            .map((item) => TeamRequest.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStore] Error parsing requests: $e');
      }
    }
    if (getActiveSessionUserId() == 'user_current' || getActiveSessionUserId() == null) {
      final leg = _box.get(_keyLegacyRequests);
      if (leg != null) {
        try {
          final List<dynamic> list = json.decode(leg as String);
          return list.map((item) => TeamRequest.fromMap(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      return SeedData.seedRequests;
    }
    return [];
  }

  static Future<void> saveRequests(List<TeamRequest> requests) async {
    final key = _userKey('requests');
    final encoded = json.encode(requests.map((r) => r.toMap()).toList());
    await _box.put(key, encoded);
    if (getActiveSessionUserId() == 'user_current') await _box.put(_keyLegacyRequests, encoded);
  }

  // Tasks (Isolated per account)
  static List<TeamTask> getTasks() {
    final key = _userKey('tasks');
    final raw = _box.get(key);
    if (raw != null) {
      try {
        final List<dynamic> list = json.decode(raw as String);
        return list
            .map((item) => TeamTask.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStore] Error parsing tasks: $e');
      }
    }
    if (getActiveSessionUserId() == 'user_current' || getActiveSessionUserId() == null) {
      final leg = _box.get(_keyLegacyTasks);
      if (leg != null) {
        try {
          final List<dynamic> list = json.decode(leg as String);
          return list.map((item) => TeamTask.fromMap(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      return SeedData.seedTasks;
    }
    return [];
  }

  static Future<void> saveTasks(List<TeamTask> tasks) async {
    final key = _userKey('tasks');
    final encoded = json.encode(tasks.map((t) => t.toMap()).toList());
    await _box.put(key, encoded);
    if (getActiveSessionUserId() == 'user_current') await _box.put(_keyLegacyTasks, encoded);
  }

  // Chat Messages (Isolated per account/team)
  static List<ChatMessage> getChatMessages() {
    final key = _userKey('chat_messages');
    final raw = _box.get(key);
    if (raw != null) {
      try {
        final List<dynamic> list = json.decode(raw as String);
        return list
            .map((item) => ChatMessage.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStore] Error parsing chat: $e');
      }
    }
    if (getActiveSessionUserId() == 'user_current' || getActiveSessionUserId() == null) {
      final leg = _box.get(_keyLegacyChatMessages);
      if (leg != null) {
        try {
          final List<dynamic> list = json.decode(leg as String);
          return list.map((item) => ChatMessage.fromMap(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      return SeedData.seedMessages;
    }
    return [];
  }

  static Future<void> saveChatMessages(List<ChatMessage> messages) async {
    final key = _userKey('chat_messages');
    final encoded = json.encode(messages.map((m) => m.toMap()).toList());
    await _box.put(key, encoded);
    if (getActiveSessionUserId() == 'user_current') await _box.put(_keyLegacyChatMessages, encoded);
  }

  // Filter Presets (Isolated per account)
  static List<FilterPreset> getFilterPresets() {
    final key = _userKey('presets');
    final raw = _box.get(key);
    if (raw != null) {
      try {
        final List<dynamic> list = json.decode(raw as String);
        return list
            .map((item) => FilterPreset.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStore] Error parsing presets: $e');
      }
    }
    if (getActiveSessionUserId() == 'user_current' || getActiveSessionUserId() == null) {
      return SeedData.seedPresets;
    }
    return [];
  }

  static Future<void> saveFilterPresets(List<FilterPreset> presets) async {
    final key = _userKey('presets');
    final encoded = json.encode(presets.map((p) => p.toMap()).toList());
    await _box.put(key, encoded);
    if (getActiveSessionUserId() == 'user_current') await _box.put(_keyLegacyPresets, encoded);
  }

  // Theme Mode
  static Future<void> saveThemeMode(String mode) async {
    await _box.put(_keyThemeMode, mode);
  }

  static String getThemeMode() {
    return _box.get(_keyThemeMode, defaultValue: 'light') as String;
  }
}
