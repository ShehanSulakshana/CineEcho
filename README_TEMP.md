# 🎬 CineEcho

<div align="center">

![CineEcho Poster](https://via.placeholder.com/1200x600?text=CineEcho+App+Poster) <!-- Add your poster link here -->

**Your Ultimate Movie & TV Show Discovery Platform**

[![Flutter](https://img.shields.io/badge/Flutter-3.10.3-blue?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?style=for-the-badge&logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-blueviolet?style=for-the-badge)](https://flutter.dev)

</div>

---

## 📱 About CineEcho

CineEcho is a comprehensive Flutter mobile application that revolutionizes how you discover, track, and share your favorite movies and TV shows. Built with modern technologies and powered by The Movie Database (TMDB) API, CineEcho provides a seamless entertainment experience with social features and personalized recommendations.

---

## ✨ Key Features

<div align="center">

| Feature | Description |
|---------|-------------|
| 🎭 **Movie & TV Discovery** | Browse trending, popular, and upcoming content with detailed metadata |
| 📊 **Comprehensive Stats Display** | View runtime, ratings, release dates, genres, and detailed overview for every movie/TV show |
| 👨‍🎬 **Cast & Crew Discovery** | Explore cast information and find other movies/shows featuring your favorite actors |
| ❤️ **Favorites Management** | Mark movies and TV series as favorites for quick access and tracking |
| ✅ **Watch History Tracking** | Track all watched movies and episodes with automatic timestamps |
| 📈 **Viewing Statistics** | Animated stats showing total watch time, movies watched, and episodes watched |
| 🔍 **Advanced Search** | Find movies, shows, and people (actors, directors) with powerful search capabilities |
| 👥 **User Profiles** | Create profiles and view your comprehensive viewing statistics |
| 🌙 **Dark Mode** | Eye-friendly dark mode support for comfortable viewing |
| 🔐 **Secure Authentication** | Google Sign-In and Firebase authentication for secure access |
| 🎞️ **Trailer Support** | Watch trailers of a movie/tv series |

</div>

---

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK**: Version 3.10.3 or higher
- **Dart**: Included with Flutter
- **Android Studio** or **Xcode** (for mobile development)
- **TMDB API Key**: Get it from [TMDB API](https://www.themoviedb.org/settings/api)
- **Firebase Project**: Set up at [Firebase Console](https://console.firebase.google.com)

### Installation Steps

```bash
# Clone the repository
git clone https://github.com/ShehanSulakshana/CineEcho.git
cd cine_echo

# Install dependencies
flutter pub get

# Configure environment variables
# Create a .env file with your TMDB API key and Firebase credentials
# (See Environment Configuration section below)

# Run the app
flutter run
```

### Environment Configuration

Create a `.env` file in the root directory with the following variables:

```env
TMDB_API_KEY=your_tmdb_api_key_here
FIREBASE_PROJECT_ID=cine-echo-app
```

---

## 🏗️ Project Architecture

CineEcho follows a clean, modular architecture for scalability and maintainability:

```
lib/
├── config/                    # Configuration files and constants
├── models/                    # Data models and entities
├── providers/                 # State management with Provider
├── screens/                   # UI screens and pages
│   ├── auth/                  # Authentication screens
│   ├── home_screen.dart       # Home/Dashboard
│   ├── search_screen.dart     # Search functionality
│   ├── profile_tabs/          # Profile and user-related screens
│   └── specific/              # Detail screens for movies/shows
├── services/                  # API calls and business logic
├── themes/                    # App theming and styling
├── widgets/                   # Reusable UI components
├── firebase_options.dart      # Firebase configuration
└── main.dart                  # App entry point
```

---

## 🛠️ Tech Stack

<div align="center">

| Category | Technology |
|----------|-----------|
| **Frontend Framework** | Flutter 3.10.3 |
| **State Management** | Provider 6.1.5 |
| **Authentication** | Firebase Auth + Google Sign-In |
| **Database** | Cloud Firestore, Hive (Local) |
| **API Integration** | TMDB API, HTTP Client |
| **Storage** | Flutter Secure Storage |
| **UI Components** | Material Design 3, Heroicons |
| **Data Processing** | Intl, Redacted |
| **Utilities** | URL Launcher, Image Picker, Connectivity Plus |

</div>

---

## 📋 Dependencies Overview

### Core Dependencies
- **firebase_core** (v4.3.0) - Firebase initialization
- **firebase_auth** (v6.1.3) - User authentication
- **cloud_firestore** (v6.1.1) - Cloud database
- **google_sign_in** (v6.2.2) - Google authentication
- **provider** (v6.1.5) - State management

### UI & UX
- **flutter_carousel_widget** (v3.1.0) - Carousel sliders
- **heroicons** (v0.9.0) - Icon library
- **marquee** (v2.1.0) - Scrolling text
- **flutter_launcher_icons** (v0.14.4) - App icons

### Data & Storage
- **hive** (v2.2.3) - Local database
- **hive_flutter** (v1.1.0) - Hive integration
- **http** (v1.6.0) - HTTP requests
- **intl** (v0.20.2) - Internationalization

### Utilities
- **flutter_secure_storage** (v9.0.0) - Secure data storage
- **connectivity_plus** (v5.0.0) - Network connectivity
- **url_launcher** (v6.3.2) - URL handling
- **image_picker** (v1.0.0) - Media selection
- **envied** (v1.3.2) - Environment variables

---

## 🎯 Core Features Explained

### 🎭 Movie & TV Show Discovery
- Browse trending, popular, and upcoming titles
- View comprehensive metadata including cast, crew, and ratings
- Access detailed information about movies and TV shows

### �‍🎬 Cast & Crew Discovery
- View detailed cast and crew information for each movie/TV show
- Explore filmographies of your favorite actors and directors
- Discover other movies and shows featuring specific actors
- Find and follow actors you're interested in

### �📋 Watchlist Management
- Create personalized watchlists, TV shows
- Mark items as watched

### 🔍 Smart Search
- Full-text search across movies and TV shows and even People (Actors , Directors)
- Auto-suggestions for popular titles

### 👤 User Profiles
- Create and customize your profile
- View viewing statistics and history
- Manage preferences and settings

---

## 🔐 Security Features

- **Secure Authentication**: Firebase Authentication with Google Sign-In
- **Data Encryption**: Encrypted local storage using Flutter Secure Storage
- **Firestore Rules**: Custom security rules for database access
- **API Key Protection**: Environment-based API key management

---


## 🚀 Build & Deployment

### Android Build
```bash
flutter build apk --release
flutter build appbundle --release
```

### Web Build
```bash
flutter build web --release
```

---

## 📚 Project Structure

### Config Layer
- App constants and configuration
- API endpoints and settings

### Models Layer
- Data models for Movies, TV Shows, Users, Posts
- Entity definitions

### Providers Layer
- State management using Provider
- Business logic and data handling

### Screens Layer
- Authentication flows
- Home/Dashboard
- Search and discovery
- User profiles
- Detail pages

### Services Layer
- API integration
- Firebase operations
- Local storage management

### Themes Layer
- Color schemes
- Typography
- Component styles

### Widgets Layer
- Reusable UI components
- Custom widgets
- Common UI elements

---


### Contribution Guidelines
- Follow Flutter best practices
- Write clean, documented code
- Test your changes thoroughly
- Update documentation as needed

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**CineEcho Development Team**
- **Repository**: [ShehanSulakshana/CineEcho](https://github.com/ShehanSulakshana/CineEcho)
- **Built with** ❤️ **using Flutter**

---

## 📊 Project Statistics

<div align="center">

![Flutter Version](https://img.shields.io/badge/Flutter-3.10.3-blue)
![API Integration](https://img.shields.io/badge/API-TMDB-yellow)
![Database](https://img.shields.io/badge/Database-Firebase-orange)
![State Management](https://img.shields.io/badge/State-Provider-green)

</div>

---

<div align="center">

**Made with passion by developers who love movies and great code** 🎬✨


</div>

