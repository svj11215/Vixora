/// Service for Google Sign-In and Firebase Authentication, including Firestore user document management.
library;

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/utils/app_exception.dart';
import 'package:vixora/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '349794555781-2667stec9gq49bfiu3ol6gd49g3o9fv0.apps.googleusercontent.com',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes for reactive UI updates.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in with Google and creates/fetches the user document in Firestore.
  ///
  /// [role] must be either 'staff' or 'resident'.
  Future<UserModel> signInWithGoogle(String role) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AppException('sign-in-cancelled', 'Sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AppException(
          'auth-failed',
          'Failed to authenticate with Firebase',
        );
      }

      // Check if user doc exists
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        // Existing user — update their FCM token if needed
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(firebaseUser.uid)
              .update({AppConstants.fieldFcmToken: fcmToken});
        }
        // Return their stored model
        return UserModel.fromMap(userDoc.data()!);
      }

      // New user — create the document
      String userCode;
      if (role == AppConstants.roleResident) {
        userCode = await _generateUniqueResidentCode();
      } else {
        userCode = AppConstants.staffCode;
      }

      final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';

      final newUser = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        role: role,
        userCode: userCode,
        flatNo: '',
        fcmToken: fcmToken,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(newUser.toMap());

      return newUser;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed') {
        throw AppException(
          'sign_in_failed',
          'Google Sign-In failed: ${e.message ?? "Check SHA-1 and package name configuration"}',
        );
      }
      throw AppException(e.code, e.message ?? 'Platform error occurred');
    } on AppException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AppException(e.code, e.message ?? 'Authentication error occurred');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('unknown', 'An unexpected error occurred: $e');
    }
  }

  /// Fetches the [UserModel] for the currently signed-in user.
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to fetch user data');
    } catch (e) {
      throw const AppException('network-error', 'Check your connection');
    }
  }

  /// Signs out from both Google and Firebase, clearing all cached credentials.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to sign out');
    } catch (e) {
      throw AppException('sign-out-error', 'Failed to sign out: $e');
    }
  }

  /// Generates a unique 4-digit numeric resident code not already in use.
  Future<String> _generateUniqueResidentCode() async {
    final random = Random();
    String code;
    bool isUnique = false;

    do {
      code = (1000 + random.nextInt(9000)).toString(); // 1000–9999
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where(AppConstants.fieldUserCode, isEqualTo: code)
          .limit(1)
          .get();
      isUnique = query.docs.isEmpty;
    } while (!isUnique);

    return code;
  }
}
