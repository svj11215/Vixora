# Vixora — Apartment Visitor Management System

A real-time apartment visitor management app built with Flutter, Firebase, and Cloudinary. Guards submit visitor requests with photos, and residents approve or reject them in real-time with push notifications.

---

## Prerequisites

| Tool              | Version   | Install                                      |
|-------------------|-----------|----------------------------------------------|
| Flutter SDK       | Stable    | https://docs.flutter.dev/get-started/install |
| Node.js           | 18+       | https://nodejs.org/                          |
| Firebase CLI      | Latest    | `npm install -g firebase-tools`              |
| FlutterFire CLI   | Latest    | `dart pub global activate flutterfire_cli`   |

---

## Setup Instructions

### 1. Clone & Install Dependencies

```bash
git clone <repo-url>
cd Vixora
flutter pub get
```

### 2. Google Services

The `google-services.json` is already placed at `android/app/google-services.json`.

### 3. FlutterFire Configure (Optional — regenerates `firebase_options.dart`)

```bash
flutterfire configure --project=vixora-dc924
```

### 4. Firebase Console Setup

1. **Authentication** → Sign-in method → Enable **Google**
2. **Cloud Firestore** → Create database (production mode)
3. **Cloud Messaging** → Enabled by default

### 5. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### 6. Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

### 7. Deploy Cloud Functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 8. Run the App

```bash
flutter run
```

---

## Testing the Full Flow

### Step 1 — Create a Resident Account
1. Open the app on Device A (or emulator).
2. Tap **"Sign in as Resident"** → Sign in with a Google account.
3. Note the **4-digit Resident Code** displayed on the Requests screen.

### Step 2 — Create a Guard Account
1. Open the app on Device B (or another emulator).
2. Tap **"Sign in as Guard"** → Sign in with a **different** Google account.

### Step 3 — Submit a Visitor Request
1. On the Guard device, go to **Add Request**.
2. Fill in visitor name, phone, select purpose.
3. Enter the **resident code** from Step 1.
4. Take/select a visitor photo → waits for Cloudinary upload.
5. Tap **Submit Request** → "Request submitted successfully".

### Step 4 — Approve/Reject (Resident)
1. On the Resident device, a **push notification** arrives.
2. Open the **Requests** tab → tap the pending request.
3. Optionally add a resolution note.
4. Tap **Approve** or **Reject**.
5. The Guard device updates in **real-time**.

---

## Architecture

```
lib/
├── main.dart                    ← Entry point, MultiProvider setup
├── firebase_options.dart        ← FlutterFire config
├── core/                        ← Constants, theme, validators
├── models/                      ← UserModel, VisitorRequestModel
├── services/                    ← Auth, Firestore, Cloudinary, FCM
├── providers/                   ← ChangeNotifier state management
├── screens/                     ← Auth, Guard, Resident, Shared screens
└── widgets/                     ← Reusable UI components
```

## Tech Stack

- **Flutter** (Dart) — Cross-platform UI
- **Firebase Auth** — Google Sign-In
- **Cloud Firestore** — Real-time database
- **Firebase Cloud Messaging** — Push notifications
- **Cloud Functions** — Server-side notification triggers
- **Cloudinary** — Image upload & hosting
- **Provider** — State management

---

© 2026 Vixora. All rights reserved.

