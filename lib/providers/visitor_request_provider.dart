/// Provider for visitor request operations: submit, update status, delete, and real-time streams.
library;

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/utils/app_exception.dart';
import 'package:vixora/models/user_model.dart';
import 'package:vixora/models/visitor_request_model.dart';
import 'package:vixora/services/cloudinary_service.dart';
import 'package:vixora/services/fcm_service.dart';
import 'package:vixora/services/firestore_service.dart';

class VisitorRequestProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool _isSubmitting = false;
  bool _isUploading = false;
  String? _submitError;
  String? _uploadedImageUrl;

  /// Whether a submission is currently in progress.
  bool get isSubmitting => _isSubmitting;

  /// Whether an image is currently being uploaded.
  bool get isUploading => _isUploading;

  /// The last submit error message, or null.
  String? get submitError => _submitError;

  /// The URL of the last uploaded image, or null.
  String? get uploadedImageUrl => _uploadedImageUrl;

  /// Returns a real-time stream of visitor requests for a guard.
  Stream<List<VisitorRequestModel>> guardRequestsStream(String guardId) {
    return _firestoreService.guardRequestsStream(guardId);
  }

  /// Returns a real-time stream of visitor requests for a resident.
  Stream<List<VisitorRequestModel>> residentRequestsStream(String residentId) {
    return _firestoreService.residentRequestsStream(residentId);
  }

  /// Uploads a visitor photo to Cloudinary and stores the URL.
  Future<String?> uploadVisitorPhoto(File imageFile) async {
    _isUploading = true;
    _submitError = null;
    notifyListeners();

    try {
      final url = await _cloudinaryService.uploadImage(imageFile);
      _uploadedImageUrl = url;
      return url;
    } on AppException catch (e) {
      _submitError = e.message;
      return null;
    } catch (e) {
      _submitError = 'Failed to upload image';
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Looks up a resident by their 4-digit code.
  ///
  /// Returns the [UserModel] if found, null otherwise.
  Future<UserModel?> lookupResidentByCode(String code) async {
    try {
      return await _firestoreService.lookupResidentByCode(code);
    } on AppException catch (e) {
      _submitError = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _submitError = 'Failed to lookup resident';
      notifyListeners();
      return null;
    }
  }

  /// Submits a new visitor request to Firestore and sends FCM notification to resident.
  Future<bool> submitVisitorRequest({
    required String visitorName,
    required String visitorPhone,
    required String purpose,
    required String imageUrl,
    required String residentCode,
    required String residentId,
    required String guardId,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final request = VisitorRequestModel(
        id: '',
        visitorName: visitorName,
        visitorPhone: visitorPhone,
        purpose: purpose,
        imageUrl: imageUrl,
        residentCode: residentCode,
        residentId: residentId,
        guardId: guardId,
        status: AppConstants.statusPending,
        createdAt: Timestamp.now(),
      );

      // Create the visitor request and get the document ID
      final docId = await _firestoreService.createVisitorRequest(request);

      // Fetch the resident's FCM token from Firestore
      try {
        final residentDoc = await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(residentId)
            .get();

        if (residentDoc.exists) {
          final fcmToken = residentDoc.data()?[AppConstants.fieldFcmToken];

          // Send FCM notification if token exists
          if (fcmToken != null && fcmToken.isNotEmpty) {
            try {
              await FcmService().sendNotification(
                fcmToken: fcmToken,
                visitorName: visitorName,
                purpose: purpose,
                requestId: docId,
              );
            } catch (e) {
              print(
                '[VisitorRequestProvider] Failed to send FCM notification: $e',
              );
              // Log the error but don't fail the submission
            }
          } else {
            print(
              '[VisitorRequestProvider] Resident $residentId has no FCM token',
            );
          }
        } else {
          print(
            '[VisitorRequestProvider] Resident document not found: $residentId',
          );
        }
      } catch (e) {
        print('[VisitorRequestProvider] Error fetching resident data: $e');
        // Log the error but don't fail the submission
      }

      _uploadedImageUrl = null;
      return true;
    } on AppException catch (e) {
      _submitError = e.message;
      return false;
    } catch (e) {
      _submitError = 'Failed to submit request';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Updates the status of a visitor request (approve or reject).
  Future<bool> updateRequestStatus({
    required String requestId,
    required String status,
    String? resolutionNote,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _firestoreService.updateVisitorRequestStatus(
        requestId: requestId,
        status: status,
        resolutionNote: resolutionNote,
      );
      return true;
    } on AppException catch (e) {
      _submitError = e.message;
      return false;
    } catch (e) {
      _submitError = 'Failed to update request';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Deletes a visitor request.
  Future<bool> deleteRequest(String id) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _firestoreService.deleteVisitorRequest(id);
      return true;
    } on AppException catch (e) {
      _submitError = e.message;
      return false;
    } catch (e) {
      _submitError = 'Failed to delete request';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Clears the uploaded image URL and any error.
  void clearState() {
    _uploadedImageUrl = null;
    _submitError = null;
    notifyListeners();
  }

  /// Clears any stored error.
  void clearError() {
    _submitError = null;
    notifyListeners();
  }
}
