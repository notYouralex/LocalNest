asd# LocalNest 🏠

A Flutter-based mobile application for finding and listing rental properties. LocalNest connects landlords with tenants, making it easy to discover boarding houses, apartments, and shared rooms in your local area.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![License](https://img.shields.io/badge/License-Private-red.svg)

## 📱 Features

### For Tenants
- **Browse Listings** - Explore available rental properties with photos and detailed information
- **Advanced Search** - Filter properties by location, price, room type, and gender preference
- **Interactive Maps** - View property locations on an integrated map
- **Favorites** - Save and manage your favorite listings
- **Direct Messaging** - Communicate directly with landlords
- **User Profiles** - Manage your profile and preferences

### For Landlords
- **Create Listings** - Post properties with multiple photos, descriptions, and amenities
- **Manage Properties** - Update availability, pricing, and listing status
- **Analytics** - Track views and inquiries for your listings
- **Messaging** - Respond to tenant inquiries

### General Features
- **Authentication** - Secure sign-in with Email/Password, Google, and Facebook
- **Real-time Updates** - Powered by Firebase Cloud Firestore
- **Location Services** - GPS-based property discovery
- **Image Upload** - Cloud-based image storage via Cloudinary

## 🏗️ Architecture

The app follows a **feature-first** architecture with clean separation of concerns:

```
lib/
├── app/
│   ├── router/          # GoRouter navigation configuration
│   └── theme/           # App-wide theming
├── core/
│   ├── config/          # App configuration
│   ├── models/          # Shared models
│   ├── services/        # Core services
│   └── widgets/         # Reusable widgets
├── features/
│   ├── authentication/  # Login, registration, auth management
│   ├── favorites/       # Saved listings management
│   ├── home/            # Home screen and dashboard
│   ├── listings/        # Property listing models & repositories
│   ├── listing_detail/  # Detailed property view
│   ├── messages/        # In-app messaging system
│   ├── profile/         # User profile management
│   └── search/          # Search and filtering
├── firebase_options.dart
└── main.dart
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.9.2 |
| **State Management** | flutter_bloc (BLoC/Cubit) |
| **Navigation** | go_router |
| **Backend** | Firebase (Auth, Firestore) |
| **Authentication** | Firebase Auth, Google Sign-In |
| **Maps** | flutter_map with OpenStreetMap |
| **Location** | geolocator |
| **Image Handling** | image_picker, Cloudinary |
| **Local Storage** | flutter_secure_storage, shared_preferences |
| **Form Validation** | formz |

## 📋 Prerequisites

- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2
- Android Studio / VS Code
- Firebase project configured
- Cloudinary account (for image uploads)

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd local_nest
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download and place configuration files:
   - `google-services.json` in `android/app/`
   - `GoogleService-Info.plist` in `ios/Runner/`
4. The `firebase_options.dart` is auto-generated via FlutterFire CLI

### 4. Configure Environment Variables

Set up your Cloudinary credentials and any other API keys in your environment configuration.

### 5. Run the app

```bash
flutter run
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔧 Build Commands

```bash
# Development build
flutter run

# Release build for Android
flutter build apk --release

# Release build for iOS
flutter build ios --release

# Web build
flutter build web

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## 📂 Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1      # State management
  go_router: ^17.0.1        # Navigation
  firebase_core: ^3.15.2    # Firebase core
  firebase_auth: ^5.3.4     # Authentication
  cloud_firestore: ^5.6.12  # Database
  google_sign_in: ^6.2.0    # Google authentication
  flutter_map: ^6.1.0       # Maps integration
  geolocator: ^10.1.0       # Location services
  image_picker: ^1.0.7      # Image selection
  flutter_secure_storage: ^9.2.0  # Secure storage
```

## 🤝 Contributing

This is a private project. Please contact the project maintainers for contribution guidelines.

## 📄 License

This project is private and not licensed for public distribution.

## 📞 Support

For support, please contact the development team.

---

**LocalNest** - *Find Your Perfect Home* 🏠
