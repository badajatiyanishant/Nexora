import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Roles that require PIN authentication.
enum AuthRole { kitchen, admin }

/// Authentication state for a single role.
class AuthRoleState {
  const AuthRoleState({
    this.isAuthenticated = false,
    this.failedAttempts = 0,
    this.lockoutUntil,
  });

  final bool isAuthenticated;
  final int failedAttempts;
  final DateTime? lockoutUntil;

  bool get isLockedOut =>
      lockoutUntil != null && DateTime.now().isBefore(lockoutUntil!);

  AuthRoleState copyWith({
    bool? isAuthenticated,
    int? failedAttempts,
    DateTime? lockoutUntil,
  }) =>
      AuthRoleState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        failedAttempts: failedAttempts ?? this.failedAttempts,
        lockoutUntil: lockoutUntil,
      );
}

/// PIN definitions — will come from Firebase settings in production.
const Map<AuthRole, String> _pins = {
  AuthRole.kitchen: '4832',
  AuthRole.admin: '987654',
};

const int _maxAttempts = 5;
const Duration _lockoutDuration = Duration(seconds: 30);

/// Session storage keys.
const _sessionKeyKitchen = 'auth_kitchen';
const _sessionKeyAdmin = 'auth_admin';

class AuthNotifier extends StateNotifier<AuthRoleState> {
  AuthNotifier(this._role, this._prefs) : super(const AuthRoleState()) {
    // Restore session from storage.
    final saved = _prefs.getBool(_sessionKey(_role)) ?? false;
    if (saved) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  final AuthRole _role;
  final SharedPreferences _prefs;

  String _sessionKey(AuthRole role) => switch (role) {
        AuthRole.kitchen => _sessionKeyKitchen,
        AuthRole.admin => _sessionKeyAdmin,
      };

  /// Attempt to authenticate with the given PIN.
  /// Returns true if successful.
  bool attemptPin(String pin) {
    if (state.isLockedOut) return false;

    if (pin == _pins[_role]) {
      state = state.copyWith(
        isAuthenticated: true,
        failedAttempts: 0,
        lockoutUntil: null,
      );
      _prefs.setBool(_sessionKey(_role), true);
      return true;
    }

    final newAttempts = state.failedAttempts + 1;
    if (newAttempts >= _maxAttempts) {
      state = state.copyWith(
        failedAttempts: newAttempts,
        lockoutUntil: DateTime.now().add(_lockoutDuration),
      );
    } else {
      state = state.copyWith(failedAttempts: newAttempts);
    }
    return false;
  }

  /// Clear remaining lockout time so user can retry immediately.
  void clearLockout() {
    state = state.copyWith(failedAttempts: 0, lockoutUntil: null);
  }

  /// Logout: clear session and reset state.
  void logout() {
    state = const AuthRoleState();
    _prefs.remove(_sessionKey(_role));
  }

  /// Seconds remaining in lockout, or 0.
  int get lockoutSeconds {
    if (!state.isLockedOut) return 0;
    return state.lockoutUntil!.difference(DateTime.now()).inSeconds + 1;
  }
}

/// Provider for kitchen auth.
final kitchenAuthProvider =
    StateNotifierProvider<AuthNotifier, AuthRoleState>((ref) {
  throw UnimplementedError('Must be overridden by ProviderScope');
});

/// Provider for admin auth.
final adminAuthProvider =
    StateNotifierProvider<AuthNotifier, AuthRoleState>((ref) {
  throw UnimplementedError('Must be overridden by ProviderScope');
});

/// Initializes auth providers with SharedPreferences.
///
/// Call this in main() before runApp() so the providers are available.
Future<List<Override>> initAuthProviders() async {
  final prefs = await SharedPreferences.getInstance();
  return [
    kitchenAuthProvider.overrideWith(
      (ref) => AuthNotifier(AuthRole.kitchen, prefs),
    ),
    adminAuthProvider.overrideWith(
      (ref) => AuthNotifier(AuthRole.admin, prefs),
    ),
  ];
}
