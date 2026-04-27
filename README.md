<div align="center">

<!-- ANIMATED HEADER BANNER -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=C6F135&height=200&section=header&text=VIXORA&fontSize=80&fontColor=111318&fontAlignY=38&desc=Real-time%20Apartment%20Visitor%20Management&descAlignY=60&descSize=18&descColor=111318&animation=fadeIn" width="100%"/>

<!-- ANIMATED TYPING SVG -->
<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=16&pause=1000&color=C6F135&background=00000000&center=true&vCenter=true&width=600&height=50&lines=Guards+submit.+Residents+decide.+In+under+2+seconds.;Real-time+photographic+visitor+verification.;No+logbooks.+No+phone+calls.+No+guessing.;Built+with+Flutter+%2B+Firebase+%2B+Cloudinary." alt="Typing SVG" />

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-BaaS-FFCA28?style=for-the-badge&logo=firebase&logoColor=111318)](https://firebase.google.com)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-CDN-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)](https://cloudinary.com)

[![License MIT](https://img.shields.io/badge/License-MIT-C6F135?style=for-the-badge&logo=opensourceinitiative&logoColor=111318)](LICENSE)
[![PRD](https://img.shields.io/badge/PRD-v1.0.0-00E5CC?style=for-the-badge&logo=readthedocs&logoColor=white)](docs/PRD.md)
[![Status](https://img.shields.io/badge/Status-Production_Ready-00C896?style=for-the-badge&logo=checkmarx&logoColor=white)]()
[![Platform](https://img.shields.io/badge/Platform-iOS_%7C_Android-F5F7FA?style=for-the-badge&logo=apple&logoColor=111318)]()

<br/>

> **Vixora** eliminates manual visitor logbooks with a real-time photographic verification system.  
> Security guards capture & submit. Residents approve or reject — instantly, from anywhere.

<br/>

</div>

---

## ✨ Features

<div align="center">

| 🔐 Authentication | 📸 Verification | 🔔 Notifications | 📊 Management |
|:---:|:---:|:---:|:---:|
| Google OAuth 2.0 | Live camera capture | Real-time FCM push | Digital audit trail |
| Role-based access | Cloudinary CDN | Sub-2s delivery | Status timestamps |
| Auto session restore | Photo compression | Background + terminated | Filter by date/status |
| FCM token auto-refresh | Gallery support | Local fallback listener | Resolution notes |

</div>

---

## 🛠️ Tech Stack

<div align="center">

| Layer | Technology | Version | Purpose |
|:---:|:---:|:---:|:---|
| 📱 **Frontend** | ![Flutter](https://img.shields.io/badge/-Flutter-02569B?logo=flutter&logoColor=white&style=flat-square) | `3.x` | Cross-platform iOS + Android |
| 🔐 **Auth** | ![Firebase](https://img.shields.io/badge/-Firebase_Auth-FFCA28?logo=firebase&logoColor=111318&style=flat-square) | `5.x` | Google OAuth, session management |
| 🗄️ **Database** | ![Firestore](https://img.shields.io/badge/-Cloud_Firestore-FFCA28?logo=firebase&logoColor=111318&style=flat-square) | `5.x` | Real-time NoSQL, offline sync |
| 🔔 **Push** | ![FCM](https://img.shields.io/badge/-FCM-FFCA28?logo=firebase&logoColor=111318&style=flat-square) | `15.x` | Push notifications (sub-2s) |
| 🖼️ **Images** | ![Cloudinary](https://img.shields.io/badge/-Cloudinary-3448C5?logo=cloudinary&logoColor=white&style=flat-square) | Latest | CDN image storage + compression |
| ⚙️ **State** | ![Provider](https://img.shields.io/badge/-Provider-0175C2?logo=dart&logoColor=white&style=flat-square) | `6.x` | Reactive state management |
| ☁️ **Backend** | ![Node.js](https://img.shields.io/badge/-Cloud_Functions-339933?logo=node.js&logoColor=white&style=flat-square) | `18.x` | Serverless FCM trigger |

</div>

---

## 🎨 Design System

<div align="center">

| Token | Swatch | Hex | Usage |
|:---:|:---:|:---:|:---|
| Background | ![#111318](https://placehold.co/20x20/111318/111318) | `#111318` | App background |
| Surface | ![#1C1F2A](https://placehold.co/20x20/1C1F2A/1C1F2A) | `#1C1F2A` | Card backgrounds |
| Primary | ![#C6F135](https://placehold.co/20x20/C6F135/C6F135) | `#C6F135` | Lime — actions & highlights |
| Accent | ![#00E5CC](https://placehold.co/20x20/00E5CC/00E5CC) | `#00E5CC` | Cyan — secondary accents |
| Approved | ![#00C896](https://placehold.co/20x20/00C896/00C896) | `#00C896` | Success state |
| Rejected | ![#FF4565](https://placehold.co/20x20/FF4565/FF4565) | `#FF4565` | Error / danger |
| Pending | ![#FFB547](https://placehold.co/20x20/FFB547/FFB547) | `#FFB547` | Warning state |
| Text Primary | ![#F5F7FA](https://placehold.co/20x20/F5F7FA/F5F7FA) | `#F5F7FA` | Main text |
| Text Secondary | ![#8892A4](https://placehold.co/20x20/8892A4/8892A4) | `#8892A4` | Secondary text |

**Font:** `DM Sans` (Google Fonts) · **Spacing Grid:** 8pt · **Border Radius:** 8 / 14 / 18 / 24 / 100pt

</div>

---

## 🧪 Testing

<details>
<summary><b>✅ Manual Testing Checklist</b></summary>

**Authentication**
- [x] Guard signs in with Google
- [x] Resident gets unique 4-digit code on first sign-in
- [x] App restart restores session (SplashScreen → `loadUser`)
- [x] FCM token stored and refreshed on rotation

**Guard Flow**
- [x] Camera capture works
- [x] Gallery selection works
- [x] Cloudinary upload returns secure URL
- [x] Request created in Firestore with `status: "pending"`
- [x] Invalid resident code returns error gracefully
- [x] Form validation enforced (name ≥ 2 chars, phone ≥ 10 digits, photo required)

**Resident Flow**
- [x] Push notification received when app is in foreground
- [x] Push notification received when app is in background
- [x] Push notification received when app is terminated
- [x] Tapping notification navigates to `RequestDetailScreen`
- [x] Approve sets `status: "approved"` + `approvedAt` timestamp
- [x] Reject sets `status: "rejected"` + `approvedAt` timestamp
- [x] Optional resolution note saved to Firestore

**Real-time Sync**
- [x] Guard's list updates immediately after resident action
- [x] Status badge changes without manual refresh

**Session**
- [x] Sign out clears FCM listener and Firebase Auth session

</details>

---

## 📦 Dependencies

<details>
<summary><b>View pubspec.yaml</b></summary>

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core:        ^3.x
  firebase_auth:        ^5.x
  cloud_firestore:      ^5.x
  firebase_messaging:   ^15.x
  firebase_crashlytics: ^4.x

  # Auth
  google_sign_in: ^6.x

  # Notifications
  flutter_local_notifications: ^18.x

  # Images
  image_picker:         ^1.x
  cached_network_image: ^3.x
  http:                 ^1.x

  # State
  provider: ^6.x

  # UI
  google_fonts: ^6.x
  shimmer:      ^3.x
```

</details>

---

## 📄 License

```
ARTF License — Copyright (c) 2026 Vixora Engineering Team
```

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=C6F135&height=120&section=footer" width="100%"/>

**Built with ❤️ by the Shreyash**

[![Flutter](https://img.shields.io/badge/Flutter-blue?style=flat-square&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-orange?style=flat-square&logo=firebase)](https://firebase.google.com)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-purple?style=flat-square&logo=cloudinary)](https://cloudinary.com)

*⭐ Star this repo if Vixora helped you!*

</div>
