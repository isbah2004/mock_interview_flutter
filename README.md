# InterviewAce (Mockee)

A Mock Interview application built with Flutter.

## Getting Started

### Prerequisites

Before running the app, you need to set up the secret configuration files.

1. **App Secrets Configuration:**
   Copy `lib/core/constants/app_secrets.example.dart` to `lib/core/constants/app_secrets.dart` and fill in your Appwrite, Gemini, and other API credentials.
   ```bash
   cp lib/core/constants/app_secrets.example.dart lib/core/constants/app_secrets.dart
   ```

2. **Firebase Configuration:**
   Copy `lib/firebase_options.example.dart` to `lib/firebase_options.dart` and fill in your Firebase project details.
   ```bash
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   ```

### Running the App

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Architecture Overview

The application follows a **Feature-Driven Clean Architecture**. This structure organizes code primarily by feature, making it modular, scalable, and easy to maintain. Each feature contains its own presentation, domain, and data layers where applicable.

### Folder Structure

The `lib/` directory is split into two main areas:
- **`core/`**: Contains application-wide shared resources.
- **`features/`**: Contains isolated feature modules.

```text
lib/
├── core/
│   ├── constants/    # Global constants, API endpoints, App Secrets
│   ├── cubits/       # Global state management (e.g., ThemeCubit, UserCubit)
│   ├── di/           # Dependency Injection setup (get_it, injectable)
│   ├── entities/     # Global domain entities
│   ├── enums/        # Application-wide enumerations
│   ├── error/        # Error handling, failures, exceptions
│   ├── extensions/   # Dart extension methods
│   ├── models/       # Global data models
│   ├── navigation/   # Routing logic (AppRouter, routes configuration)
│   ├── services/     # Global services (Network, Storage, etc.)
│   ├── theme/        # Light/Dark mode definitions
│   ├── usecases/     # Base use case definitions
│   ├── utils/        # Helper functions, loggers
│   └── widgets/      # Shared/Reusable UI components
├── features/
│   ├── ads/              # Google Mobile Ads integration
│   ├── auth/             # Authentication (Google, Facebook, Firebase)
│   ├── history/          # User's past interview sessions
│   ├── home/             # Main dashboard and bottom navigation
│   ├── mcqinterviews/    # Multiple-choice mock interviews
│   ├── onboarding/       # App initialization and intro flows
│   └── voiceinterviews/  # Voice-based mock interviews (Speech-to-Text & TTS)
└── main.dart         # Application entry point and Provider setup
```

## Technology Stack

### State Management
- **Bloc / Cubit** (`flutter_bloc`): Used for managing both global state (Theme, User, Navigation) and feature-specific state (Interviews, Auth).

### Dependency Injection
- **GetIt** & **Injectable**: Used for managing service locators and automatically generating dependency graphs.

### Backend & Authentication
- **Firebase Core & Auth**: Primary authentication platform.
- **Google Sign-In & Facebook Auth**: Social login providers.
- **Appwrite**: Used alongside Firebase for database/backend operations (configured in `app_secrets.dart`).

### Local Storage
- **GetStorage**: Fast, synchronous key-value storage for local preferences (e.g., theme, onboarding status).

### Functional Programming & Error Handling
- **Fpdart**: Used for functional programming paradigms, specifically `Either` types for robust error handling (Left for Failure, Right for Success).

### Voice & Speech
- **Speech to Text** (`speech_to_text`): Captures user's voice during mock interviews.
- **Text to Speech** (`flutter_tts`): Synthesizes AI interviewer's voice responses.

### Monetization
- **Google Mobile Ads**: For banner and interstitial ad placements.

## Core Features

1. **Voice Mock Interviews (`voiceinterviews`)**
   - Simulates a real interview using Speech-to-Text and Text-to-Speech.
   - Evaluates user responses using Gemini AI (API key configured in secrets).
   
2. **MCQ Mock Interviews (`mcqinterviews`)**
   - Multiple-choice technical and behavioral questions.
   - Includes a timer (`TimerCubit`) for timed assessments.

3. **Authentication (`auth`)**
   - Multi-provider login flow (Google, Facebook).
   - Validates user sessions and interacts with backend services.

4. **History (`history`)**
   - Keeps track of past performance and interview scores.

5. **Monetization (`ads`)**
   - Integrated ad services initialized during app startup. Non-blocking initialization ensures app stability even if ads fail to load.

## State & Initialization Flow

The application initializes in `main.dart` with the following sequence:
1. **Widgets Binding & Splash**: Retains the native splash screen while initializing async dependencies.
2. **Storage & Firebase**: Initializes `GetStorage` and `Firebase`.
3. **Dependency Injection**: Sets up `serviceLocator` via `initializeDependencies()`.
4. **Ad Service**: Attempts to initialize `AdIntegrationService` (non-blocking).
5. **App Run**: Launches `MyApp`, wrapping the `MaterialApp` with a `MultiBlocProvider` that injects all necessary global Cubits and Blocs (Theme, Auth, User, Home, etc.).

## Security

- **App Secrets**: Sensitive keys (Appwrite IDs, Gemini API Key, Firebase configs) are kept out of source control.
- Developers must duplicate `.example.dart` files and populate them locally to run the app.
