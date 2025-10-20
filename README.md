# 📚 Book Memo App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue)]()

English | [日本語](README_ja.md)

A reading management and memo application built with Flutter. Support your entire reading life from managing books of interest, taking notes while reading, to recording impressions after completion.

## ✨ Key Features

### 📖 Book Management
- **Easy Registration**: Register book title, author, and publisher
- **📸 Book Cover Images**: 
  - Auto-fetch from Google Books API
  - Take photos with camera
  - Select from gallery
- **Purchase URL**: Save links to Amazon, etc.
- **Status Management**: Interested 💭 / Reading 📖 / Completed ⭐
- **Rating Feature**: 5-star rating system
- **Recommendations**: Record reasons for interest and recommendations

### 📝 Memo Features
- **Overall Memo**: Impressions and reviews for the entire book
- **Page Memo**: Notes linked to specific pages or chapters
- **Memo Types**:
  - 📝 General Notes
  - 💬 Quotes
  - 💡 Insights
  - ❓ Questions
- **Quote Feature**: Record impressive passages
- **Page Numbers**: Record corresponding pages

### 🔍 Search & Filter
- Search by book title and author name
- Status-based display (from Drawer menu)
- Easy switching between Reading, Completed, and Interested books

### 🔗 Sharing Features
- SNS Sharing: Share book information and memos
- URL Links: One-tap access to purchase links
- Memo Sharing: Share individual page memos

### 🎨 UI/UX
- **Material Design 3**: Modern design system
- **Material You Support**: Auto-generate color schemes based on wallpaper (Android 12+)
- **Theme Switching**: Light / Dark / System settings (3 modes)
- **IBM Plex Sans JP Font**: Readable Japanese font
- **Book Cover Display**: Visually clear list view
- **Drawer Menu**: Intuitive navigation
- **Card-based UI**: Clear book list
- **Tab Switching**: Switch between overall and page memos
- **Responsive Design**: Automatically switches to grid layout on tablets and landscape orientation
- **Custom Swipe Gesture**: Center-screen swipe to open drawer (no conflict with Android 12+ gesture navigation)

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: Provider
- **Database**: 
  - Android/iOS: SQLite (sqflite)
  - Windows/Linux/macOS: SQLite (sqflite_common_ffi)
  - Web: IndexedDB (sqflite_common_ffi_web)
- **Major Packages**:
  - `provider` - State management
  - `sqflite` / `sqflite_common` / `sqflite_common_ffi` / `sqflite_common_ffi_web` - Database
  - `flutter_rating_bar` - Star rating UI
  - `cached_network_image` - Image caching
  - `image_picker` - Camera & gallery integration
  - `http` - Google Books API communication
  - `url_launcher` - URL launching
  - `share_plus` - SNS sharing
  - `intl` - Date formatting
  - `uuid` - ID generation
  - `dynamic_color` - Material You support
  - `shared_preferences` - Settings storage
  - `google_fonts` - IBM Plex Sans JP font
  - `flutter_launcher_icons` - Auto-generate app icons

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── database_init.dart           # Desktop DB initialization
├── database_init_web.dart       # Web DB initialization
├── database_init_stub.dart      # Stub implementation
├── models/                      # Data models
│   ├── book.dart               # Book model
│   └── page_memo.dart          # Page memo model
├── providers/                   # State management
│   ├── book_provider.dart      # Book provider
│   ├── memo_provider.dart      # Memo provider
│   └── theme_provider.dart     # Theme provider
├── database/                    # Database
│   └── database_helper.dart    # SQLite helper
├── screens/                     # Screens
│   ├── home_screen.dart        # Home screen
│   ├── books_by_status_screen.dart  # Status-based list
│   ├── add_book_screen.dart    # Add/Edit book
│   ├── book_detail_screen.dart # Book details
│   ├── add_memo_screen.dart    # Add/Edit memo
│   └── settings_screen.dart    # Settings screen
└── widgets/                     # Common widgets
    ├── app_drawer.dart         # Drawer menu
    └── book_card.dart          # Book card
```

## 🚀 Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Additional Setup for Web (Web version only)

```bash
dart run sqflite_common_ffi_web:setup
```

### 3. Run the App

**Windows:**
```bash
flutter run -d windows
```

**Web:**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run
```

### 4. Generate App Icons (First time only)

```bash
dart run flutter_launcher_icons
```

## 📱 Requirements

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Supported Platforms: Android / iOS / Windows / macOS / Linux / Web

### Platform-Specific Requirements

**Windows:**
- Enable Developer Mode (Settings → Update & Security → For developers → Developer mode ON)
- Visual Studio 2022 (C++ desktop development tools)

**Web:**
- Run `dart run sqflite_common_ffi_web:setup` before first launch

## 💡 Usage

### 1. Add a Book
1. Tap the "Add Book" button at the bottom right of the home screen
2. Enter book title and author name (required)
3. Enter publisher and purchase URL (optional)
4. Set status and rating
5. Write recommendations
6. Tap "Add"

### 2. Add a Memo
1. Open the book details screen
2. Select the "Page Memo" tab
3. Tap the "Add Memo" button
4. Select memo type
5. Enter page number and quote (optional)
6. Write memo content
7. Tap "Add"

### 3. Status-Based Display
1. Tap the hamburger menu (☰) at the top left, or swipe right from the center of the screen
2. Select "Reading," "Completed," or "Interested"
3. Display only books with the selected status

### 4. Sharing

- **Share Book**: Tap the share button at the top right of the details screen
- **Share Memo**: Tap the share icon on each memo card

### 5. Theme Switching

- **Quick Toggle**: Tap the theme icon at the top right of the home screen
- **Detailed Settings**: Drawer Menu → Settings → Appearance
  - Light Mode: Bright theme
  - Dark Mode: Dark theme
  - Follow System Settings: Automatically adapt to device settings
- **Material You**: On Android 12+, automatically generates color schemes based on wallpaper

## 🎓 Learning Points

This project is a practical sample app for Flutter beginners. You can learn:

- ✅ **CRUD Operations**: Create, Read, Update, Delete with SQLite
- ✅ **State Management**: State management with Provider
- ✅ **Screen Navigation**: Multi-screen navigation
- ✅ **Form Handling**: User input validation
- ✅ **List Display**: Dynamic list generation
- ✅ **Tab UI**: Using TabBar and TabBarView
- ✅ **Drawer Menu**: Side menu implementation
- ✅ **External Integration**: URL launching and SNS sharing
- ✅ **Responsive Design**: Tablet and landscape support
- ✅ **Multi-Platform**: Android/iOS/Windows/Web support
- ✅ **Material Design 3**: Latest design system
- ✅ **Custom Gestures**: Touch operation optimization

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses

This project uses the following open-source packages:
- [Flutter](https://github.com/flutter/flutter) - BSD-3-Clause License
- [Provider](https://pub.dev/packages/provider) - MIT License
- [sqflite](https://pub.dev/packages/sqflite) - MIT License
- [Google Fonts](https://pub.dev/packages/google_fonts) - Apache-2.0 License

For a complete list of dependencies and their licenses, see [pubspec.yaml](pubspec.yaml).

---

**Happy Reading! 📚✨**

