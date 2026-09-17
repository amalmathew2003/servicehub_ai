<div align="center">

# 🔧 ServiceHub AI

### *AI-Powered Service Booking Platform*

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Connected-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Groq](https://img.shields.io/badge/Groq-AI%20Powered-FF4B4B?style=for-the-badge&logo=openai&logoColor=white)](https://groq.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<br/>

> **ServiceHub AI** is a next-generation service booking app where users simply *describe their problem in natural language* and our Groq-powered AI assistant understands, clarifies, and connects them with the best available nearby professionals — instantly.

<br/>

---

</div>

## ✨ What Makes It Special

Unlike traditional booking apps where you manually browse categories, **ServiceHub AI** uses a conversational AI (Groq LLM) to:

- 🤖 **Understand the problem** — "My kitchen pipe is leaking near the sink" instantly identifies a plumber is needed
- ❓ **Ask smart follow-up questions** — AI gathers missing details before searching for staff
- 📍 **Find real, nearby professionals** — Live location, availability, and distance-aware matching
- 📱 **Live tracking** — See the service professional navigate to you in real-time
- ⭐ **Seamless ratings** — Rate the service once it's complete

---

## 🖥️ UI Design

The app features a stunning **dark neo-neumorphic UI** with:

- 🎨 Deep dark background (`#161618`) with **hot pink neon accent** (`#E92E5F`)
- 🌀 Animated **Smart Home dial** with sweeping glowing tick marks on the background
- 🪟 **Glassmorphism cards** — translucent, frosted-glass login and register forms
- 💫 **Smooth fade transitions** between all pages (400ms cross-fade)
- 📐 Fully **responsive** layout for mobile, tablet, and web

---

## 🏗️ Architecture

This project follows **Clean Architecture** with a **Feature-Based Folder Structure**, making it modular, testable, and scalable.

```
lib/
├── core/
│   ├── service/          # GetIt dependency injection
│   └── theme/            # App color constants & design tokens
│       └── app_colors.dart
│
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/    # Firebase Auth datasource
│       │   └── models/         # AppUserModel (JSON serialization)
│       │
│       ├── domain/
│       │   ├── entities/       # AppUser entity (pure Dart)
│       │   ├── repositories/   # AuthRepository interface
│       │   └── usecases/       # Login, Register, Google, Logout, GetCurrentUser
│       │
│       └── presentation/
│           ├── bloc/           # AuthBloc, AuthEvent, AuthState
│           ├── pages/          # LoginPage, RegisterPage, AuthGate, HomePlaceholder
│           └── widgets/        # AnimatedBackground, RoleChip
│
└── main.dart
```

### Data Flow

```
UI (Widgets)
     ↓  dispatches events
  AuthBloc
     ↓  calls
  UseCase(s)
     ↓  calls
  AuthRepository (interface)
     ↓  implemented by
  AuthRepositoryImpl
     ↓  calls
  AuthDatasource
     ↓  calls
  Firebase Auth / Firestore
```

---

## ⚙️ Tech Stack

| Layer | Technology |
|---|---|
| **UI Framework** | Flutter 3.x (Dart) |
| **State Management** | BLoC (flutter_bloc) |
| **Dependency Injection** | GetIt |
| **Navigation** | GoRouter |
| **HTTP Client** | Dio |
| **Authentication** | Firebase Auth (Email + Google) |
| **Database** | Cloud Firestore |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **File Storage** | Firebase Storage |
| **AI / NLP** | Groq API (LLaMA-based) |
| **Location** | Geolocator |
| **Maps** | Google Maps Flutter |

---

## 🚀 Features

### ✅ Completed (MVP Phase 1)

| Feature | Status |
|---|---|
| Firebase project setup & connection | ✅ Done |
| Email/Password Authentication | ✅ Done |
| Google Sign-In | ✅ Done |
| Clean Architecture scaffold | ✅ Done |
| AppUser entity & model | ✅ Done |
| Auth repository & datasource | ✅ Done |
| Register / Login use cases | ✅ Done |
| AuthBloc (events, states) | ✅ Done |
| Login Page (dark glassmorphism UI) | ✅ Done |
| Register Page (with role selection) | ✅ Done |
| AuthGate (route guard) | ✅ Done |
| GetIt dependency injection | ✅ Done |
| Animated background (dial meter) | ✅ Done |
| Smooth page transitions (fade) | ✅ Done |
| Centralized color constants | ✅ Done |

### 🔜 In Progress (MVP Phase 2+)

| Feature | Status |
|---|---|
| Role-based navigation (User vs Staff) | 🔜 Next |
| Staff profile & service selection | 🔜 Planned |
| Staff availability & live location | 🔜 Planned |
| User Home & service categories | 🔜 Planned |
| AI Chat UI | 🔜 Planned |
| Groq integration & tool calling | 🔜 Planned |
| Nearby staff search & matching | 🔜 Planned |
| Booking flow & status updates | 🔜 Planned |
| FCM push notifications | 🔜 Planned |
| Live map tracking | 🔜 Planned |
| Service ratings & reviews | 🔜 Planned |

---

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK `^3.13.2`
- Dart SDK `^3.x`
- Firebase CLI
- A Firebase project with Auth and Firestore enabled
- A Groq API key (for AI features)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/service_hub_ai.git
cd service_hub_ai

# 2. Install dependencies
flutter pub get

# 3. Set up Firebase
# Follow the FlutterFire CLI setup:
# https://firebase.google.com/docs/flutter/setup
flutterfire configure

# 4. Run the app
flutter run
```

### Environment Variables

Create a `.env` file in the project root (add to `.gitignore`):

```
GROQ_API_KEY=your_groq_api_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

---

## 🎨 Design System

All colors are centralized in [`lib/core/theme/app_colors.dart`](lib/core/theme/app_colors.dart):

| Token | Value | Usage |
|---|---|---|
| `background` | `#161618` | Main app background |
| `surface` | `#1E1E20` | Card & dialog surfaces |
| `primary` | `#E92E5F` | Hot pink neon accent |
| `textLight` | `#F5F5F5` | Primary text |
| `textLightSecondary` | `#A0A0A8` | Secondary text & labels |
| `borderLight` | `#2E2E32` | Dividers & borders |

---

## 🧠 AI Architecture Note

> **Groq = Conversation and understanding.**
> **Firebase / Cloud Functions = Trusted business logic and real data.**

The Groq LLM is **never** allowed to invent staff members, availability, distance, or booking results. It is only used for:
- Understanding the user's natural language problem description
- Asking clarifying follow-up questions
- Structuring the query to pass to the backend (Firebase Cloud Functions)

All real data (staff, bookings, location) lives exclusively in Firestore and is served by Cloud Functions.

---

## 📁 Key Files

| File | Purpose |
|---|---|
| [`lib/main.dart`](lib/main.dart) | App entry point, DI initialization |
| [`lib/core/theme/app_colors.dart`](lib/core/theme/app_colors.dart) | Global design tokens |
| [`lib/features/auth/presentation/bloc/auth_bloc.dart`](lib/features/auth/presentation/bloc/auth_bloc.dart) | Authentication state machine |
| [`lib/features/auth/presentation/pages/login_page.dart`](lib/features/auth/presentation/pages/login_page.dart) | Login UI |
| [`lib/features/auth/presentation/pages/register_page.dart`](lib/features/auth/presentation/pages/register_page.dart) | Registration UI |
| [`lib/features/auth/presentation/widgets/animated_background.dart`](lib/features/auth/presentation/widgets/animated_background.dart) | CustomPainter dial animation |

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ using Flutter & Firebase**

*ServiceHub AI — Connecting people with trusted service professionals, powered by AI.*

</div>
