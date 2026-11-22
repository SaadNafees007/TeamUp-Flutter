import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/user_account.dart';
import '../../../data/local_storage/local_store.dart';
import '../services/auth_service.dart';
import '../../profile/providers/profile_provider.dart';
import '../../team/providers/team_provider.dart';
import '../../requests/providers/requests_provider.dart';
import '../../discover/providers/discover_provider.dart';

class AuthState {
  final UserAccount? account;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.account,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => account != null;

  AuthState copyWith({
    UserAccount? account,
    bool clearAccount = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      account: clearAccount ? null : (account ?? this.account),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState(isLoading: true)) {
    checkSession();
  }

  /// Check whether an authenticated session exists in persistent storage
  void checkSession() {
    final activeId = LocalStore.getActiveSessionUserId();
    if (activeId != null) {
      final account = LocalStore.findAccountById(activeId);
      if (account != null) {
        state = AuthState(account: account, isLoading: false);
        return;
      }
    }
    state = AuthState(account: null, isLoading: false);
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await AuthService.login(email: email, password: password);
      state = AuthState(account: account, isLoading: false);
      _refreshUserIsolatedData();
      return true;
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  /// Create a new account with data isolation
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );
      state = AuthState(account: account, isLoading: false);
      _refreshUserIsolatedData();
      return true;
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  /// Logout and clear in-memory user-specific state
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await AuthService.logout();
    state = AuthState(account: null, isLoading: false);
    _refreshUserIsolatedData();
  }

  /// Invalidate user-scoped providers to guarantee complete data isolation between accounts
  void _refreshUserIsolatedData() {
    _ref.invalidate(profileProvider);
    _ref.invalidate(teamProvider);
    _ref.invalidate(requestsProvider);
    _ref.invalidate(discoverProvider);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
