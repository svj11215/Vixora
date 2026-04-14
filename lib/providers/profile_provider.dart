/// Provider for user profile management: load, update name, refresh FCM token.
library;

import 'package:flutter/foundation.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/utils/app_exception.dart';
import 'package:vixora/models/user_model.dart';
import 'package:vixora/services/fcm_service.dart';
import 'package:vixora/services/firestore_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FCMTokenService _fcmTokenService = FCMTokenService();

  UserModel? _profile;
  bool _isSaving = false;
  String? _error;

  /// The loaded user profile.
  UserModel? get profile => _profile;

  /// Whether a save operation is in progress.
  bool get isSaving => _isSaving;

  /// The last error message, or null.
  String? get error => _error;

  /// Loads the user profile from Firestore.
  Future<void> loadProfile(String uid) async {
    try {
      _profile = await _firestoreService.getUser(uid);
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profile';
      notifyListeners();
    }
  }

  /// Updates the user's display name in Firestore.
  Future<bool> updateName(String uid, String name) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateUser(uid, {AppConstants.fieldName: name});
      _profile = _profile?.copyWith(name: name);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to update name';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Refreshes the FCM token in Firestore for push notifications.
  Future<void> refreshFcmToken(String uid) async {
    try {
      await _fcmTokenService.initializeFCM(uid);
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh notification token';
      notifyListeners();
    }
  }

  /// Sets the profile directly (used when profile is already loaded from auth).
  void setProfile(UserModel user) {
    _profile = user;
    notifyListeners();
  }

  /// Clears any stored error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
