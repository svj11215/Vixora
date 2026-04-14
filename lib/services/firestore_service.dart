/// Service for all Firestore CRUD operations and real-time streams.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/utils/app_exception.dart';
import 'package:vixora/models/user_model.dart';
import 'package:vixora/models/visitor_request_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── User Operations ──

  /// Fetches a user document by UID.
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to fetch user');
    } catch (e) {
      throw const AppException('network-error', 'Check your connection');
    }
  }

  /// Updates specific fields on a user document.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(data);
    } on FirebaseException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to update user');
    } catch (e) {
      throw const AppException('network-error', 'Check your connection');
    }
  }

  /// Looks up a resident by their unique 4-digit code.
  ///
  /// Returns the [UserModel] if found, null otherwise.
  Future<UserModel?> lookupResidentByCode(String code) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where(AppConstants.fieldUserCode, isEqualTo: code)
          .where(AppConstants.fieldRole, isEqualTo: AppConstants.roleResident)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return UserModel.fromMap(query.docs.first.data());
    } on FirebaseException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to lookup resident');
    } catch (e) {
      throw const AppException('network-error', 'Check your connection');
    }
  }

  // ── Visitor Request Operations ──

  /// Creates a new visitor request document in Firestore.
  /// Returns the ID of the newly created document.
  Future<String> createVisitorRequest(VisitorRequestModel request) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.visitorRequestsCollection)
          .add(request.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to create request');
    } catch (e) {
      throw const AppException('network-error', 'Check your connection');
    }
  }

  /// Updates the status and optional fields of a visitor request.
  Future<void> updateVisitorRequestStatus({
    required String requestId,
    required String status,
    String? resolutionNote,
  }) async {
    try {
      final data = <String, dynamic>{
        AppConstants.fieldStatus: status,
        AppConstants.fieldApprovedAt: Timestamp.now(),
      };
      if (resolutionNote != null && resolutionNote.isNotEmpty) {
        data[AppConstants.fieldResolutionNote] = resolutionNote;
      }

      await _firestore
          .collection(AppConstants.visitorRequestsCollection)
          .doc(requestId)
          .update(data);
    } on FirebaseException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to update request');
    } catch (e) {
      throw const AppException('network-error', 'Check your connection');
    }
  }

  /// Deletes a visitor request document.
  Future<void> deleteVisitorRequest(String requestId) async {
    try {
      await _firestore
          .collection(AppConstants.visitorRequestsCollection)
          .doc(requestId)
          .delete();
    } on FirebaseException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to delete request');
    } catch (e) {
      throw const AppException('network-error', 'Check your connection');
    }
  }

  /// Returns a real-time stream of visitor requests for a specific guard,
  /// ordered by [createdAt] descending.
  Stream<List<VisitorRequestModel>> guardRequestsStream(String guardId) {
    return _firestore
        .collection(AppConstants.visitorRequestsCollection)
        .where(AppConstants.fieldGuardId, isEqualTo: guardId)
        .orderBy(AppConstants.fieldCreatedAt, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VisitorRequestModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Returns a real-time stream of visitor requests for a specific resident,
  /// ordered by [createdAt] ascending (first-come first-serve).
  Stream<List<VisitorRequestModel>> residentRequestsStream(String residentId) {
    return _firestore
        .collection(AppConstants.visitorRequestsCollection)
        .where(AppConstants.fieldResidentId, isEqualTo: residentId)
        .orderBy(AppConstants.fieldCreatedAt, descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VisitorRequestModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Updates the FCM token for a user.
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update(
        {AppConstants.fieldFcmToken: token},
      );
    } on FirebaseException catch (e) {
      throw AppException(e.code, e.message ?? 'Failed to update FCM token');
    } catch (e) {
      throw const AppException('network-error', 'Check your connection');
    }
  }
}
