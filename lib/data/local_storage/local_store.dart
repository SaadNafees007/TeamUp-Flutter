import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/student_profile.dart';
import '../models/team.dart';
import '../models/team_request.dart';
import '../models/team_task.dart';
import '../models/chat_message.dart';
import '../models/filter_preset.dart';
import '../seed/seed_data.dart';

class LocalStore {
  static const String _appBoxName = 'teamup_storage_box';

  static const String _keyIsSeeded = 'key_is_seeded';
  static const String _keyCurrentUser = 'key_current_user';
  static const String _keyStudents = 'key_students';
  static const String _keyTeam = 'key_team';
  static const String _keyRequests = 'key_requests';
  static const String _keyTasks = 'key_tasks';
  static const String _keyChatMessages = 'key_chat_messages';
  static const String _keyPresets = 'key_presets';

  static late Box _box;

  /// Initialize Hive and load or seed data
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_appBoxName);

    final bool isAlreadySeeded =
        _box.get(_keyIsSeeded, defaultValue: false) as bool;
    if (!isAlreadySeeded) {
      debugPrint(
        '[LocalStore] First-time launch detected. Initializing seed dataset...',
      );
      await _seedInitialData();
    } else {
      debugPrint(
        '[LocalStore] Persistent storage already initialized. Loaded from Hive.',
      );
    }
  }

  static Future<void> _seedInitialData() async {
    // Current User
    await saveCurrentUser(SeedData.defaultCurrentUser);

    // Student Profiles
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

    // Mark seeded
    await _box.put(_keyIsSeeded, true);
  }

  /// Hard reset to seed data (useful for judge testing/demo reset)
  static Future<void> resetToSeedData() async {
    await _box.clear();
    await _seedInitialData();
  }

  // Current User
  static StudentProfile getCurrentUser() {
    final raw = _box.get(_keyCurrentUser);
    if (raw != null) {
      try {
        return StudentProfile.fromJson(raw as String);
      } catch (e) {
        debugPrint('[LocalStore] Error parsing current user: $e');
      }
    }
    return SeedData.defaultCurrentUser;
  }

  static Future<void> saveCurrentUser(StudentProfile user) async {
    await _box.put(_keyCurrentUser, user.toJson());
  }

  // Students (Peers/Candidates)
  static List<StudentProfile> getStudents() {
    final raw = _box.get(_keyStudents);
    if (raw != null) {
      try {
        final List<dynamic> list = json.decode(raw as String);
        return list
            .map((item) => StudentProfile.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStore] Error parsing students: $e');
      }
    }
    return SeedData.seedStudents;
  }

  static Future<void> saveStudents(List<StudentProfile> students) async {
    final encoded = json.encode(students.map((s) => s.toMap()).toList());
    await _box.put(_keyStudents, encoded);
  }

  // Team
  static Team? getTeam() {
    final raw = _box.get(_keyTeam);
    if (raw != null) {
      try {
        return Team.fromJson(raw as String);
      } catch (e) {
        debugPrint('[LocalStore] Error parsing team: $e');
      }
    }
    return SeedData.defaultTeam;
  }

  static Future<void> saveTeam(Team? team) async {
    if (team == null) {
      await _box.delete(_keyTeam);
    } else {
      await _box.put(_keyTeam, team.toJson());
    }
  }

  // Requests
  static List<TeamRequest> getRequests() {
    final raw = _box.get(_keyRequests);
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
    return SeedData.seedRequests;
  }

  static Future<void> saveRequests(List<TeamRequest> requests) async {
    final encoded = json.encode(requests.map((r) => r.toMap()).toList());
    await _box.put(_keyRequests, encoded);
  }

  // Tasks
  static List<TeamTask> getTasks() {
    final raw = _box.get(_keyTasks);
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
    return SeedData.seedTasks;
  }

  static Future<void> saveTasks(List<TeamTask> tasks) async {
    final encoded = json.encode(tasks.map((t) => t.toMap()).toList());
    await _box.put(_keyTasks, encoded);
  }

  // Chat Messages
  static List<ChatMessage> getChatMessages() {
    final raw = _box.get(_keyChatMessages);
    if (raw != null) {
      try {
        final List<dynamic> list = json.decode(raw as String);
        return list
            .map((item) => ChatMessage.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStore] Error parsing chat messages: $e');
      }
    }
    return SeedData.seedMessages;
  }

  static Future<void> saveChatMessages(List<ChatMessage> messages) async {
    final encoded = json.encode(messages.map((m) => m.toMap()).toList());
    await _box.put(_keyChatMessages, encoded);
  }

  // Filter Presets
  static List<FilterPreset> getFilterPresets() {
    final raw = _box.get(_keyPresets);
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
    return SeedData.seedPresets;
  }

  static Future<void> saveFilterPresets(List<FilterPreset> presets) async {
    final encoded = json.encode(presets.map((p) => p.toMap()).toList());
    await _box.put(_keyPresets, encoded);
  }
}
