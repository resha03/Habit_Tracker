# 🐛 Development Guide & Troubleshooting

## Common Issues & Solutions

### Build & Environment Issues

#### 1. "Flutter command not found"
```bash
# Solution: Add Flutter to PATH
# Windows (PowerShell):
$env:Path += ";C:\path\to\flutter\bin"

# Mac/Linux:
export PATH="$PATH:$HOME/path/to/flutter/bin"

# Verify:
flutter doctor
```

#### 2. "Android SDK not found"
```bash
# Solution: Install Android SDK
flutter config --android-sdk /path/to/android/sdk

# Or use Android Studio to install
```

#### 3. "No connected devices"
```bash
# List available devices
flutter devices

# Start Android emulator
emulator -avd Pixel_5_API_30

# Or start iOS simulator
open -a Simulator
```

---

### Dependency Issues

#### 1. "Pub get fails"
```bash
# Clear cache and retry
flutter clean
flutter pub get

# Or upgrade dependencies
flutter pub upgrade
```

#### 2. "Version conflict"
```bash
# Check pub lock file
cat pubspec.lock

# Force resolve
flutter pub get --offline

# Or upgrade all
flutter pub upgrade --major-versions
```

#### 3. "Package not found"
```bash
# Ensure pubspec.yaml is correct
# Then run:
flutter pub get

# Verify package installed:
flutter pub global list
```

---

### Runtime Issues

#### 1. App crashes on startup
```dart
// Check main.dart initialization
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services here
  runApp(const MyApp());
}
```

#### 2. "Late initialization error"
```dart
// Issue: Service accessed before initialization
// Solution: Initialize in main or first screen

Future<void> initialize() async {
  await storageService.initialize();
  await securityService.initializeEncryption();
}
```

#### 3. Null pointer exception
```dart
// Enable null safety checks
// Build with: flutter run --enable-nullsafety

// Or add null checks:
if (habit?.name != null) {
  print(habit!.name);
}
```

---

### Data & Storage Issues

#### 1. "Hive box already open"
```dart
// Issue: Multiple Hive box opens
// Solution: Use singleton pattern
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
}
```

#### 2. "Encrypted data corrupted"
```dart
// Check encryption key matches
// Regenerate key if lost:
Future<void> clearAndReinitialize() async {
  await securityService.clearSecureStorage();
  await securityService.initializeEncryption();
}
```

#### 3. "Database query timeout"
```dart
// Add timeout handling
Future<List<Habit>> getHabits() async {
  return Future.wait(
    habits.map((h) => _decrypt(h)),
    eagerError: true,
  ).timeout(const Duration(seconds: 5));
}
```

---

### Firebase Issues

#### 1. "Firebase not initialized"
```dart
// Ensure initialization before use
Future<void> initializeApp() async {
  await Firebase.initializeApp();
  _auth = FirebaseAuth.instance;
  _firestore = FirebaseFirestore.instance;
}
```

#### 2. "Authentication fails"
```dart
// Check Firebase project settings:
// 1. Enable Authentication in Firebase Console
// 2. Add email/password provider
// 3. Ensure google-services.json is in android/app/
// 4. Ensure GoogleService-Info.plist is in iOS/Runner/
```

#### 3. "Firestore permission denied"
```dart
// Update Firestore rules:
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/habits/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

### UI Issues

#### 1. "Widget overflow"
```dart
// Use Expanded or Flexible
Expanded(
  child: Text('Your text'),
)

// Or use SingleChildScrollView
SingleChildScrollView(
  child: Column(children: [...]),
)
```

#### 2. "Animation janky"
```dart
// Add const where possible
const HabitCard() // Improves performance

// Use AnimationController with TickerProviderStateMixin
class MyScreen extends State with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }
}
```

#### 3. "Dark mode not working"
```dart
// Ensure theme includes both light and dark
MaterialApp(
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
)

// Test dark mode:
// iOS: Settings > Developer > Dark Appearance
// Android: Settings > Display > Dark theme
```

---

### Testing Issues

#### 1. "Test fails randomly"
```dart
// Ensure proper async handling
testWidgets('test name', (WidgetTester tester) async {
  await tester.pumpWidget(...);
  await tester.pumpAndSettle(); // Wait for animations
  expect(...);
});
```

#### 2. "Mock not working"
```dart
// Use correct mock syntax
when(mockService.getHabits())
  .thenAnswer((_) async => [testHabit]);

// Verify was called
verify(mockService.getHabits()).called(1);
```

#### 3. "Widget not found in test"
```dart
// Use find with correct matcher
find.text('Habit Name')
find.byIcon(Icons.check)
find.byType(HabitCard)

// If not found, widget not rendered
// Ensure widget is in build tree
```

---

## Debug Tips

### Logging Best Practices

```dart
// Use debugPrint for Flutter debug console
import 'package:flutter/foundation.dart';

void logHabit(Habit habit) {
  if (kDebugMode) {
    debugPrint('Habit: ${habit.name}, Streak: ${habit.currentStreak}');
  }
}
```

### Using breakpoints

```dart
// In VS Code:
// 1. Click on line number to add breakpoint
// 2. Run: flutter run
// 3. Debugger pauses at breakpoint
// 4. Inspect variables in debug console
```

### Device logs

```bash
# Android
adb logcat

# iOS
xcrun simctl launch booted system

# Flutter logs
flutter logs
```

---

## Performance Optimization

### Check Performance

```bash
# Run performance test
flutter run --profile

# Frame time stats
flutter run --profile
# In app, press 'p' for performance overlay
```

### Common Performance Issues

1. **Expensive builds**
   ```dart
   // Bad: Rebuilds entire tree
   Column(children: someList.map(...).toList())
   
   // Good: Use ListView with itemBuilder
   ListView.builder(
     itemBuilder: (context, index) => ...,
   )
   ```

2. **Unnecessary rebuilds**
   ```dart
   // Use selector to rebuild only on specific change
   selector: (context, provider) => provider.habits.length,
   ```

3. **Large images**
   ```dart
   // Resize images before loading
   Image.asset(
     'assets/image.png',
     cacheWidth: 400,
     cacheHeight: 400,
   )
   ```

---

## Security Best Practices

### Always Validate Input

```dart
// Validate before using
String? error = Validators.validateHabitName(input);
if (error != null) {
  showError(error);
  return;
}
```

### Encrypt Sensitive Data

```dart
// Never store plain passwords
await securityService.storeSensitiveData(
  'password',
  encryptedPassword,
);

// Retrieve only when needed
final decrypted = await securityService.getSensitiveData('password');
```

### Don't Log Sensitive Data

```dart
// Bad: Logs password
debugPrint('Password: $password');

// Good: Only log safe info
debugPrint('Password length: ${password.length}');
```

---

## Development Workflows

### Feature Development

```bash
# 1. Create branch
git checkout -b feature/new-habit-feature

# 2. Make changes
# 3. Run tests
flutter test

# 4. Format code
dart format lib/

# 5. Run analysis
flutter analyze

# 6. Commit
git add .
git commit -m "Add new feature"
```

### Hot Reload Workflow

```bash
# Start app in debug mode
flutter run

# Make code change in editor
# Save file

# In terminal, press 'r' to hot reload
# Changes appear instantly

# Press 'R' for full restart if hot reload doesn't work
```

---

## Analytics & Debugging

### Getting Help

1. **Check Flutter docs**: https://flutter.dev/docs
2. **Search Stack Overflow**: Add `flutter` tag
3. **GitHub Issues**: Search Flutter repo
4. **Provider docs**: https://pub.dev/packages/provider
5. **Firebase docs**: https://firebase.flutter.dev/

---

## Code Analysis

### Run Analysis

```bash
# Check for issues
flutter analyze

# More detailed
dart analyze lib/ --fatal-warnings
```

### Common Issues Found

```
Warning: Always put required named parameters first
Solution: Reorder parameters

Warning: Avoid builds with side effects  
Solution: Move logic to separate methods

Warning: Avoid async gaps
Solution: Use await properly
```

---

## Release Build Troubleshooting

### APK Build Issues

```bash
# Clean build
flutter clean

# Build with verbose output
flutter build apk -v

# Common issues:
# - Signing key not found: Add keystore
# - SDK version mismatch: Update build.gradle
# - ProGuard error: Check keep rules
```

### Testing Release Build

```bash
# Build and install
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk

# Test
flutter run --release
```

---

## Memory Leaks Prevention

### Dispose Resources

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = stream.listen((_) {});
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

---

## Documentation Tips

### Writing Good Comments

```dart
// Good: Explains why
// We calculate streak here because we need to update UI
int streak = calculateStreak(dates);

// Bad: Explains what (code already does this)
// Calculate streak
int streak = calculateStreak(dates);
```

### README Structure

```
1. Overview
2. Features
3. Installation
4. Usage
5. Architecture
6. Contributing
7. License
```

---

**Remember**: 
- 🔍 Read error messages carefully - they often indicate the issue
- 🧪 Write tests for critical logic
- 🔐 Never commit sensitive data
- 📚 Keep documentation up-to-date
- 🎯 Use version control properly

**Happy coding! 🚀**
