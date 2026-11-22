import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_account.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/models/team.dart';
import '../../../data/models/team_role.dart';
import '../../../data/local_storage/local_store.dart';

class AuthService {
  /// Deterministic salted SHA-256 hash for secure local password storage
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt$password$salt');
    return sha256.convert(bytes).toString();
  }

  /// Verify entered credentials against saved account
  static bool verifyPassword(String password, UserAccount account) {
    final computed = hashPassword(password, account.salt);
    return computed == account.passwordHash;
  }

  /// Create a new local account with data isolation
  static Future<UserAccount> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    // Check if account already exists
    final existing = LocalStore.findAccountByEmail(cleanEmail);
    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }

    final salt = const Uuid().v4().substring(0, 12);
    final passwordHash = hashPassword(password, salt);
    final userId = 'user_${const Uuid().v4().substring(0, 8)}';

    final account = UserAccount(
      id: userId,
      name: cleanName,
      email: cleanEmail,
      passwordHash: passwordHash,
      salt: salt,
      createdAt: DateTime.now(),
    );

    // Save account
    await LocalStore.saveAccount(account);

    // Initialize user-isolated profile
    final initialProfile = StudentProfile(
      id: userId,
      name: cleanName,
      department: AppConstants.departments.first,
      semester: 4, // Eligible semester default (4-8)
      skills: [],
      interests: [],
      projectType: 'Final Year Project',
      availability: 'Flexible',
      bio: '',
      avatar: 'avatar_1',
      isCurrentUser: true,
    );

    // Initialize default team for new user (Max team size 3)
    final initialTeam = Team(
      id: 'team_$userId',
      title: '$cleanName\'s Project',
      description: 'Project collaboration space for competition.',
      projectType: 'Final Year Project',
      leaderId: userId,
      roles: [
        TeamRole(
          id: 'role_${userId}_lead',
          title: 'Project Lead',
          requiredSkills: ['Software Engineering'],
          assignedMemberId: userId,
        ),
      ],
      memberIds: [userId],
      memberRoleMap: {userId: 'role_${userId}_lead'},
      createdAt: DateTime.now(),
    );

    // Set active session and save initial user-specific data
    await LocalStore.setActiveSessionUserId(userId);
    await LocalStore.saveCurrentUser(initialProfile);
    await LocalStore.saveTeam(initialTeam);
    await LocalStore.saveRequests([]);
    await LocalStore.saveTasks([]);
    await LocalStore.saveChatMessages([]);

    return account;
  }

  /// Login with email and password
  static Future<UserAccount> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Check if demo account exists, if not ensure it is initialized
    final account = LocalStore.findAccountByEmail(cleanEmail);
    if (account == null) {
      throw Exception('Invalid email or password.');
    }

    if (!verifyPassword(password, account)) {
      throw Exception('Invalid email or password.');
    }

    // Persist active session ID
    await LocalStore.setActiveSessionUserId(account.id);
    return account;
  }

  /// Logout current session
  static Future<void> logout() async {
    await LocalStore.setActiveSessionUserId(null);
  }

  /// Check active session on app startup
  static String? getActiveSession() {
    return LocalStore.getActiveSessionUserId();
  }
}
