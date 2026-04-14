/// Application-wide constants including Cloudinary config, route names, and collection references.
class AppConstants {
  AppConstants._();

  // ── Cloudinary ──
  static const String cloudinaryCloudName = 'dvsokdwsb';
  static const String cloudinaryUploadPreset = 'vixora_uploads';
  static const String cloudinaryUploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';
  static const String cloudinaryFolder = 'visitors';

  // ── Firestore Collections ──
  static const String usersCollection = 'users';
  static const String visitorRequestsCollection = 'visitor_requests';

  // ── Firestore Fields ──
  static const String fieldUid = 'uid';
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldRole = 'role';
  static const String fieldUserCode = 'userCode';
  static const String fieldFlatNo = 'flatNo';
  static const String fieldFcmToken = 'fcmToken';
  static const String fieldVisitorName = 'visitorName';
  static const String fieldVisitorPhone = 'visitorPhone';
  static const String fieldPurpose = 'purpose';
  static const String fieldImageUrl = 'imageUrl';
  static const String fieldResidentCode = 'residentCode';
  static const String fieldResidentId = 'residentId';
  static const String fieldGuardId = 'guardId';
  static const String fieldStatus = 'status';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldApprovedAt = 'approvedAt';
  static const String fieldResolutionNote = 'resolutionNote';

  // ── Roles ──
  static const String roleStaff = 'staff';
  static const String roleResident = 'resident';
  static const String staffCode = 'STAFF';

  // ── Status Values ──
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // ── Route Names ──
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeGuardHome = '/guard-home';
  static const String routeResidentHome = '/resident-home';

  // ── Visit Purposes ──
  static const List<String> visitPurposes = [
    'Delivery',
    'Guest',
    'Maintenance',
    'Cab/Taxi',
    'Other',
  ];

  // ── FCM ──
  static const String notificationChannelId = 'vixora_visitors';
  static const String notificationChannelName = 'Visitor Requests';
  static const String notificationChannelDesc =
      'Notifications for visitor requests at your apartment';

  // ── App Info ──
  static const String appName = 'Vixora';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A real-time apartment visitor management system that connects security guards with residents for seamless visitor approval.';
  static const String appCopyright = '© 2026 Vixora. All rights reserved.';
}
