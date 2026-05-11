# 🚀 Quick Start Guide - Habit Tracker

Get the Habit Tracker app running in 5 minutes!

## ⚡ Quick Setup (Windows/Mac/Linux)

### 1️⃣ Install Flutter (if not already installed)
```bash
# Download Flutter from: https://flutter.dev/docs/get-started/install
# Extract and add to PATH
flutter --version
```

### 2️⃣ Clone/Open the Project
```bash
cd habit_tracker
```

### 3️⃣ Get Dependencies
```bash
flutter pub get
```

### 4️⃣ Run Code Generation (Optional but recommended)
```bash
flutter pub run build_runner build
```

### 5️⃣ Run the App
```bash
# On connected device or emulator
flutter run

# Or run on specific device
flutter run -d <device-id>
```

✅ **That's it! The app should launch in seconds.**

---

## 📱 Running on Different Platforms

### Android Emulator
```bash
# Start emulator
emulator -avd <emulator-name>

# Run app
flutter run
```

### iOS Simulator (Mac only)
```bash
# Start simulator
open -a Simulator

# Run app
flutter run
```

### Physical Device
```bash
# Connect device via USB
# Enable USB Debugging on device

flutter devices  # List connected devices
flutter run      # Will prompt which device
```

---

## 🔄 Development Workflow

### Hot Reload
```bash
# In terminal, press 'r' to hot reload
# Press 'R' to hot restart
# Press 'q' to quit
```

### Debug Mode
```bash
flutter run   # Automatically debug mode
```

### Release Mode
```bash
flutter run --release
```

### Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/habit_test.dart

# Run with coverage
flutter test --coverage
```

---

## 🐛 Troubleshooting

### Issue: "Flutter not found"
**Solution**: Add Flutter to PATH
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Issue: "No connected devices"
**Solution**: 
```bash
flutter devices
# Start emulator or connect physical device
```

### Issue: "pub get fails"
**Solution**:
```bash
flutter clean
flutter pub get
```

### Issue: "Build fails"
**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📚 Project Files Overview

```
lib/
├── main.dart               → App entry point
├── models/habit.dart       → Data model
├── providers/              → State management
├── screens/                → UI screens
├── widgets/                → Reusable components
├── services/               → Business logic
└── utils/                  → Helpers & constants

test/                       → Tests
```

---

## 🎯 Key Features to Try

1. **Create a Habit**: Tap the "+" button on home screen
2. **Track Completion**: Click the circle on any habit to mark as done
3. **View Stats**: Go to Stats tab for detailed analytics
4. **Customize**: Go to Settings for theme, notifications, data backup

---

## 🔐 Security Features

- ✅ All data encrypted locally (AES-256)
- ✅ Secure key storage
- ✅ Input validation on all forms
- ✅ No sensitive data in logs

---

## 📊 Architecture

```
UI Layer (Screens & Widgets)
        ↓
State Management (Provider)
        ↓
Services (Business Logic)
        ↓
Data Layer (Storage & Firebase)
```

---

## 🌟 Tips

- **First Run**: App initializes storage, may take a few seconds
- **Offline Mode**: Full functionality works without internet
- **Data Sync**: Changes auto-sync to Firebase when online
- **Hot Reload**: Press 'r' to see changes instantly during development

---

## 📞 Need Help?

- Check `README.md` for detailed documentation
- Read inline code comments
- Flutter docs: https://flutter.dev/docs
- Provider docs: https://pub.dev/packages/provider

---

**Happy coding! 🎉**
