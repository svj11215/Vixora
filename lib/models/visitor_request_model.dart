/// Data model representing a visitor request created by a guard for a resident.
library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vixora/core/constants/app_constants.dart';

class VisitorRequestModel {
  /// Firestore document ID.
  final String id;

  /// Name of the visitor.
  final String visitorName;

  /// Phone number of the visitor.
  final String visitorPhone;

  /// Purpose of the visit (Delivery, Guest, Maintenance, Cab/Taxi, Other).
  final String purpose;

  /// Cloudinary secure URL of the visitor's photo.
  final String imageUrl;

  /// 4-digit resident code entered by the guard.
  final String residentCode;

  /// UID of the resident resolved from [residentCode].
  final String residentId;

  /// UID of the guard who submitted this request.
  final String guardId;

  /// Status: 'pending', 'approved', or 'rejected'.
  final String status;

  /// Timestamp when the request was created.
  final Timestamp createdAt;

  /// Timestamp when the resident actioned the request (null until actioned).
  final Timestamp? approvedAt;

  /// Optional note from the resident on approval/rejection.
  final String? resolutionNote;

  const VisitorRequestModel({
    required this.id,
    required this.visitorName,
    required this.visitorPhone,
    required this.purpose,
    required this.imageUrl,
    required this.residentCode,
    required this.residentId,
    required this.guardId,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.resolutionNote,
  });

  /// Creates a [VisitorRequestModel] from a Firestore document map and its ID.
  factory VisitorRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return VisitorRequestModel(
      id: id,
      visitorName: map[AppConstants.fieldVisitorName] as String? ?? '',
      visitorPhone: map[AppConstants.fieldVisitorPhone] as String? ?? '',
      purpose: map[AppConstants.fieldPurpose] as String? ?? '',
      imageUrl: map[AppConstants.fieldImageUrl] as String? ?? '',
      residentCode: map[AppConstants.fieldResidentCode] as String? ?? '',
      residentId: map[AppConstants.fieldResidentId] as String? ?? '',
      guardId: map[AppConstants.fieldGuardId] as String? ?? '',
      status: map[AppConstants.fieldStatus] as String? ?? AppConstants.statusPending,
      createdAt: map[AppConstants.fieldCreatedAt] as Timestamp? ?? Timestamp.now(),
      approvedAt: map[AppConstants.fieldApprovedAt] as Timestamp?,
      resolutionNote: map[AppConstants.fieldResolutionNote] as String?,
    );
  }

  /// Converts this [VisitorRequestModel] to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      AppConstants.fieldVisitorName: visitorName,
      AppConstants.fieldVisitorPhone: visitorPhone,
      AppConstants.fieldPurpose: purpose,
      AppConstants.fieldImageUrl: imageUrl,
      AppConstants.fieldResidentCode: residentCode,
      AppConstants.fieldResidentId: residentId,
      AppConstants.fieldGuardId: guardId,
      AppConstants.fieldStatus: status,
      AppConstants.fieldCreatedAt: createdAt,
      if (approvedAt != null) AppConstants.fieldApprovedAt: approvedAt,
      if (resolutionNote != null) AppConstants.fieldResolutionNote: resolutionNote,
    };
  }

  /// Returns a copy of this model with optionally overridden fields.
  VisitorRequestModel copyWith({
    String? id,
    String? visitorName,
    String? visitorPhone,
    String? purpose,
    String? imageUrl,
    String? residentCode,
    String? residentId,
    String? guardId,
    String? status,
    Timestamp? createdAt,
    Timestamp? approvedAt,
    String? resolutionNote,
  }) {
    return VisitorRequestModel(
      id: id ?? this.id,
      visitorName: visitorName ?? this.visitorName,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      purpose: purpose ?? this.purpose,
      imageUrl: imageUrl ?? this.imageUrl,
      residentCode: residentCode ?? this.residentCode,
      residentId: residentId ?? this.residentId,
      guardId: guardId ?? this.guardId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }

  /// Whether this request is still pending.
  bool get isPending => status == AppConstants.statusPending;

  /// Whether this request has been approved.
  bool get isApproved => status == AppConstants.statusApproved;

  /// Whether this request has been rejected.
  bool get isRejected => status == AppConstants.statusRejected;

  @override
  String toString() =>
      'VisitorRequestModel(id: $id, visitor: $visitorName, status: $status)';
}
