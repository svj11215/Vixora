<div align="center">

<br/>

```
██╗   ██╗██╗██╗  ██╗ ██████╗ ██████╗  █████╗ 
██║   ██║██║╚██╗██╔╝██╔═══██╗██╔══██╗██╔══██╗
██║   ██║██║ ╚███╔╝ ██║   ██║██████╔╝███████║
╚██╗ ██╔╝██║ ██╔██╗ ██║   ██║██╔══██╗██╔══██║
 ╚████╔╝ ██║██╔╝ ██╗╚██████╔╝██║  ██║██║  ██║
  ╚═══╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
```

**Real-time Apartment Visitor Management System**

*Guards submit. Residents decide. In under 2 seconds.*

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-BaaS-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-CDN-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)](https://cloudinary.com)
[![License](https://img.shields.io/badge/License-MIT-C6F135?style=for-the-badge)](LICENSE)
[![PRD](https://img.shields.io/badge/PRD-v1.0.0-00E5CC?style=for-the-badge)](docs/PRD.md)
[![Status](https://img.shields.io/badge/Status-Production_Ready-00C896?style=for-the-badge)]()

<br/>

> **Vixora** eliminates manual visitor logbooks with a real-time photographic verification system.  
> Security guards capture & submit. Residents approve or reject — instantly, from anywhere.

<br/>

---

</div>

## ⚡ What Is Vixora?

Vixora is a **cross-platform mobile application** that bridges the communication gap between apartment security personnel and residents. When a visitor arrives at the gate, the guard photographs them, logs their details, and the resident receives a **real-time push notification** with a photo — and approves or rejects the request in one tap.

No logbooks. No phone calls. No guessing.

<br/>

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                         VIXORA SYSTEM FLOW                           │
├──────────────────────┬───────────────────────┬───────────────────────┤
│    GUARD (Mobile)    │    FIREBASE BACKEND    │  RESIDENT (Mobile)   │
│                      │                        │                       │
│  1. Google Sign-In ──┼──▶ Firebase Auth ◀─────┼── Google Sign-In     │
│  2. Capture Photo ───┼──▶ Cloudinary CDN       │                      │
│  3. Enter Res. Code  │                        │                       │
│  4. Submit Request ──┼──▶ Cloud Firestore ─────┼──▶ Live Stream       │
│                      │         │              │                       │
│                      │   Firebase Functions   │                       │
│                      │         │              │                       │
│  8. Status Update ◀──┼── Firestore Stream     │                       │
│                      │                        │  5. FCM Push Notif.   │
│                      │    FCM (Push) ──────────┼──▶ Tap Notification  │
│                      │                        │  6. View Visitor Photo│
│                      │                        │  7. Approve / Reject  │
└──────────────────────┴───────────────────────┴───────────────────────┘
```

<br/>

## 🛠️ Tech Stack

| Layer | Technology | Why |
|---|---|---|
| 📱 **Frontend** | Flutter (Dart) | Single codebase → iOS + Android |
| 🔐 **Auth** | Firebase Auth + Google Sign-In | Zero password management |
| 🗄️ **Database** | Cloud Firestore | Real-time sync, offline-capable |
| 🔔 **Notifications** | FCM + Cloud Functions | Sub-2s latency push notifications |
| 🖼️ **Images** | Cloudinary CDN | Compressed, cached, fast photo delivery |
| ⚙️ **State** | Provider | Reactive state across widgets |
| ☁️ **Backend** | Firebase Functions (Node.js) | Serverless, scales automatically |

<br/>

## 🚀 Getting Started

### Prerequisites

```bash
flutter --version    # 3.x or higher required
node --version       # 18.x or higher for Cloud Functions
firebase --version   # Firebase CLI installed globally
```

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/vixora.git
cd vixora
```

### 2. Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase project
flutterfire configure

# This auto-generates lib/firebase_options.dart
```

Place your platform config files:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### 3. Cloudinary Configuration

In `lib/core/constants/app_constants.dart`:

```dart
static const String cloudinaryCloudName = 'YOUR_CLOUD_NAME';
static const String cloudinaryUploadPreset = 'YOUR_UPLOAD_PRESET';
```

### 4. Install Dependencies & Run

```bash
flutter pub get
flutter run
```

### 5. Deploy Firebase Backend

```bash
# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes

# Deploy Cloud Functions (FCM trigger)
cd functions
npm install
firebase deploy --only functions
```

<br/>

## 📂 Project Structure

```
vixora/
├── 📁 lib/
│   ├── main.dart                          # App entry point
│   ├── 📁 core/
│   │   ├── constants/app_constants.dart   # Global constants
│   │   ├── theme/app_theme.dart           # Design system (colors, typography)
│   │   └── utils/
│   │       ├── validators.dart            # Form validators
│   │       └── app_exception.dart         # Error handling model
│   ├── 📁 models/
│   │   ├── user_model.dart                # User (Guard / Resident)
│   │   └── visitor_request_model.dart     # Visitor request document
│   ├── 📁 services/
│   │   ├── auth_service.dart              # Google Sign-In + role management
│   │   ├── firestore_service.dart         # CRUD + real-time streams
│   │   ├── cloudinary_service.dart        # Image upload + compression
│   │   └── fcm_service.dart               # Push notification handling
│   ├── 📁 providers/
│   │   ├── auth_provider.dart             # Authentication state
│   │   └── visitor_request_provider.dart  # Request CRUD state
│   ├── 📁 screens/
│   │   ├── auth/login_screen.dart         # Role-based sign-in
│   │   ├── guard/
│   │   │   ├── guard_home_screen.dart
│   │   │   ├── add_visitor_screen.dart    # ← Guard submits here
│   │   │   └── guard_requests_screen.dart
│   │   ├── resident/
│   │   │   ├── resident_home_screen.dart
│   │   │   ├── resident_requests_screen.dart  # ← Resident approves here
│   │   │   └── request_detail_screen.dart
│   │   └── shared/profile_screen.dart
│   └── 📁 widgets/                        # Reusable UI components
├── 📁 functions/
│   └── index.js                           # FCM trigger Cloud Function
├── firestore.rules                        # Security rules
├── firestore.indexes.json                 # Query indexes
└── pubspec.yaml
```

<br/>

## 🔐 Data Models

### `users` Collection

```json
{
  "uid": "firebase_auth_uid",
  "name": "John Smith",
  "email": "john@example.com",
  "role": "resident",           // "staff" | "resident"
  "userCode": "4821",           // 4-digit unique code (residents) | "STAFF"
  "flatNo": "B-204",            // residents only
  "fcmToken": "fcm_token_here"  // for push notifications
}
```

### `visitor_requests` Collection

```json
{
  "id": "auto_generated_id",
  "visitorName": "Mike Johnson",
  "visitorPhone": "+91 9876543210",
  "purpose": "Delivery",        // Delivery | Guest | Maintenance | Cab/Taxi | Other
  "imageUrl": "https://res.cloudinary.com/...",
  "residentCode": "4821",
  "residentId": "resident_uid",
  "guardId": "guard_uid",
  "status": "pending",          // pending | approved | rejected
  "createdAt": "Timestamp",
  "approvedAt": "Timestamp",    // optional
  "resolutionNote": "Let him in" // optional
}
```

<br/>

## 🔥 Core Features

### 👮 Guard Flow

```
Sign In (Google)  →  Enter Visitor Details  →  Capture Photo
       ↓
Upload to Cloudinary  →  Lookup Resident by 4-digit Code
       ↓
Create Firestore Request (status: "pending")
       ↓
Cloud Function triggers FCM push to resident ✅
```

**Validation Rules:**
- 📛 Name: minimum 2 characters
- 📞 Phone: minimum 10 digits
- 🔢 Resident Code: exactly 4 numeric digits  
- 📷 Photo: **mandatory** — no submission without image

### 🏠 Resident Flow

```
Receive FCM Push Notification  →  Tap to open Request Detail
       ↓
View: Visitor Photo + Name + Phone + Purpose
       ↓
  [APPROVE] ──────────────────────── [REJECT]
       ↓                                  ↓
status: "approved"               status: "rejected"
approvedAt: now()                approvedAt: now()
resolutionNote: optional         resolutionNote: optional
       ↓
Guard's list updates in REAL-TIME ✅
```

<br/>

## 🛡️ Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only access their own document
    match /users/{userId} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
    }
    
    // Visitor requests — role-based access
    match /visitor_requests/{requestId} {
      
      // Guards can create (only their own requests)
      allow create: if request.auth != null 
                    && request.resource.data.guardId == request.auth.uid;
      
      // Both guard and resident can read their own requests
      allow read: if request.auth != null 
                  && (resource.data.guardId == request.auth.uid 
                      || resource.data.residentId == request.auth.uid);
      
      // Only the target resident can update status
      allow update: if request.auth != null 
                    && resource.data.residentId == request.auth.uid
                    && request.resource.data.status != resource.data.status;
    }
  }
}
```

<br/>

## ☁️ Cloud Function — FCM Trigger

```javascript
// functions/index.js
exports.onVisitorRequestCreated = onDocumentCreated(
  "visitor_requests/{docId}",
  async (event) => {
    const request = event.data.data();
    const residentDoc = await db.collection("users").doc(request.residentId).get();
    const fcmToken = residentDoc.data()?.fcmToken;

    if (!fcmToken) return;

    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: "New Visitor Request",
        body: `${request.visitorName} is at the gate for ${request.purpose}`
      },
      data: {
        requestId: event.params.docId,
        residentId: request.residentId
      }
    });
  }
);
```

<br/>

## 🎨 Design System

| Token | Value | Usage |
|---|---|---|
| `--bg` | `#111318` | App background |
| `--surface` | `#1C1F2A` | Card backgrounds |
| `--primary` | `#C6F135` | Lime — actions, highlights |
| `--accent` | `#00E5CC` | Cyan — secondary accents |
| `--approved` | `#00C896` | Success state |
| `--rejected` | `#FF4565` | Error / danger state |
| `--pending` | `#FFB547` | Warning state |
| `--text-primary` | `#F5F7FA` | Main text |
| `--text-secondary` | `#8892A4` | Secondary text |

**Font:** DM Sans (Google Fonts) — 28px Display → 11px Label

**Spacing Grid:** 8pt — XS(4) SM(8) MD(16) LG(24) XL(32) XXL(48)

<br/>

## 📊 Firestore Indexes Required

```json
{
  "indexes": [
    {
      "collectionGroup": "visitor_requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "residentId", "order": "ASCENDING" },
        { "fieldPath": "status",     "order": "ASCENDING" },
        { "fieldPath": "createdAt",  "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "visitor_requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "guardId",    "order": "ASCENDING" },
        { "fieldPath": "createdAt",  "order": "DESCENDING" }
      ]
    }
  ]
}
```

<br/>

## 🧪 Testing Checklist

```
Authentication
  ✅ Guard can sign in with Google
  ✅ Resident gets unique 4-digit code on first sign-in
  ✅ App restart restores session (SplashScreen → loadUser)

Guard Flow
  ✅ Photo capture (camera) and selection (gallery) work
  ✅ Cloudinary upload returns secure URL
  ✅ Request created in Firestore with status: "pending"
  ✅ Invalid resident code shows error (not a crash)

Resident Flow  
  ✅ Push notification received (foreground + background + terminated)
  ✅ Tapping notification opens Request Detail screen
  ✅ Approve action sets status + approvedAt timestamp
  ✅ Reject action sets status + approvedAt timestamp
  ✅ Resolution note saved to Firestore

Real-time
  ✅ Guard's request list updates immediately after resident action
  ✅ Status badge changes color without refresh

Session
  ✅ Sign out clears FCM listener + Firebase Auth session
  ✅ FCM token refreshed on token rotation
```

<br/>

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_messaging: ^15.x
  firebase_crashlytics: ^4.x
  
  # Auth
  google_sign_in: ^6.x
  
  # Notifications
  flutter_local_notifications: ^18.x
  
  # Images
  image_picker: ^1.x
  cached_network_image: ^3.x
  http: ^1.x                    # Cloudinary upload
  
  # State
  provider: ^6.x
  
  # UI
  google_fonts: ^6.x
  shimmer: ^3.x
```

<br/>

## 🗺️ Roadmap

- [x] Real-time push notifications (FCM + Cloud Functions)
- [x] Photographic visitor verification (Cloudinary)
- [x] Role-based access (Guard / Resident)
- [x] Status audit trail with timestamps
- [ ] **Pagination** — `limit()` + `startAfter()` for large lists
- [ ] **QR code generation** for approved visitors
- [ ] **Multi-building support** — `buildingId` field
- [ ] **Batch approval** — approve multiple pending requests
- [ ] **Visitor history** — reuse profiles for repeat visitors
- [ ] **Localization** — i18n support (English, Spanish, Arabic)
- [ ] **Resident invitation** — Email/SMS onboarding
- [ ] **RTL layout** — Arabic/Hebrew support

<br/>

## 💰 Cost (Firebase Free Tier)

| Service | Free Quota | Vixora Usage |
|---|---|---|
| Firestore Reads | 50,000 / day | ✅ Well within |
| Firestore Writes | 20,000 / day | ✅ Well within |
| Cloud Functions | 2M invocations / mo | ✅ Well within |
| FCM Notifications | Unlimited | ✅ Free forever |
| Cloudinary Bandwidth | 25 GB / mo | ✅ ~2,500 photos |

> **Zero infrastructure cost** for apartment complexes under ~500 units.

<br/>

## 🤝 Contributing

```bash
# 1. Fork the repository
# 2. Create your feature branch
git checkout -b feature/visitor-qr-codes

# 3. Commit your changes
git commit -m "feat: add QR code generation for approved visitors"

# 4. Push to the branch
git push origin feature/visitor-qr-codes

# 5. Open a Pull Request
```

Please follow the existing code style and add entries to the testing checklist for new features.

<br/>

## 📄 License

```
MIT License — Copyright (c) 2026 Vixora Engineering Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software to use, copy, modify, merge, publish, and distribute without
restriction, subject to the above copyright notice appearing in all copies.
```

<br/>

---

<div align="center">

**Built with ❤️ by Shreyash Jadhav**

*Flutter · Firebase · Cloudinary*

[![Stars](https://img.shields.io/github/stars/YOUR_USERNAME/vixora?style=social)](https://github.com/YOUR_USERNAME/vixora)
[![Forks](https://img.shields.io/github/forks/YOUR_USERNAME/vixora?style=social)](https://github.com/YOUR_USERNAME/vixora)

</div>
