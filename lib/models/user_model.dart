/// Data model representing a user (guard/staff or resident) in the system.
library;
import 'package:vixora/core/constants/app_constants.dart';

class UserModel {
  /// Firebase Auth UID.
  final String uid;

  /// Display name of the user.
  final String name;

  /// Email address from Google Sign-In.
  final String email;

  /// User role: 'staff' or 'resident'.
  final String role;

  /// 4-digit numeric code for residents, 'STAFF' for guards.
  final String userCode;

  /// Flat number (e.g., 'A-102'), empty for guards.
  final String flatNo;

  /// Firebase Cloud Messaging token for push notifications.
  final String fcmToken;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.userCode,
    required this.flatNo,
    required this.fcmToken,
  });

  /// Creates a [UserModel] from a Firestore document map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[AppConstants.fieldUid] as String? ?? '',
      name: map[AppConstants.fieldName] as String? ?? '',
      email: map[AppConstants.fieldEmail] as String? ?? '',
      role: map[AppConstants.fieldRole] as String? ?? '',
      userCode: map[AppConstants.fieldUserCode] as String? ?? '',
      flatNo: map[AppConstants.fieldFlatNo] as String? ?? '',
      fcmToken: map[AppConstants.fieldFcmToken] as String? ?? '',
    );
  }

  /// Converts this [UserModel] to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      AppConstants.fieldUid: uid,
      AppConstants.fieldName: name,
      AppConstants.fieldEmail: email,
      AppConstants.fieldRole: role,
      AppConstants.fieldUserCode: userCode,
      AppConstants.fieldFlatNo: flatNo,
      AppConstants.fieldFcmToken: fcmToken,
    };
  }

  /// Returns a copy of this [UserModel] with optionally overridden fields.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? userCode,
    String? flatNo,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      userCode: userCode ?? this.userCode,
      flatNo: flatNo ?? this.flatNo,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  /// Whether this user is a security guard / staff member.
  bool get isStaff => role == AppConstants.roleStaff;

  /// Whether this user is a resident.
  bool get isResident => role == AppConstants.roleResident;

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, role: $role, userCode: $userCode)';
}
