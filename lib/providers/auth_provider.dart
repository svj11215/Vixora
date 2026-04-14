/// Provider for authentication state management using ChangeNotifier.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/utils/app_exception.dart';
import 'package:vixora/models/user_model.dart';
import 'package:vixora/services/auth_service.dart';
import 'package:vixora/services/fcm_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FCMTokenService _fcmTokenService = FCMTokenService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  /// The currently authenticated user model, or null if not logged in.
  UserModel? get currentUser => _currentUser;

  /// Whether an authentication operation is in progress.
  bool get isLoading => _isLoading;

  /// The last error message, or null if no error.
  String? get error => _error;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _currentUser != null;

  /// Signs in as a guard (staff role) using Google Sign-In.
  Future<void> signInAsGuard() async {
    await _signIn(AppConstants.roleStaff);
  }

  /// Signs in as a resident using Google Sign-In.
  Future<void> signInAsResident() async {
    await _signIn(AppConstants.roleResident);
  }

  /// Internal sign-in method that handles the full auth flow.
  Future<void> _signIn(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle(role);
      _currentUser = user;

      // Initialize FCM after successful sign-in
      await _fcmTokenService.initializeFCM(user.uid);
    } on AppException catch (e) {
      _error = e.message;
      _currentUser = null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads the user model for the currently signed-in Firebase user.
  ///
  /// Used on app restart from SplashScreen to restore session.
  Future<void> loadUser() async {
    // Defer listener notification until after frame is built
    void _notify() {
      if (!kIsWeb)
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
    }

    _isLoading = true;
    _error = null;
    _notify();

    try {
      final user = await _authService.getCurrentUserModel();
      _currentUser = user;

      if (user != null) {
        // Re-initialize FCM on app restart
        await _fcmTokenService.initializeFCM(user.uid);
      }
    } on AppException catch (e) {
      _error = e.message;
      _currentUser = null;
    } catch (e) {
      _error = 'Failed to load user data';
      _currentUser = null;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Signs out the current user, clearing all state.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to sign out';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears any stored error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
