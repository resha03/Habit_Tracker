# 🏗️ Architecture & Design Patterns

## Overview

The Habit Tracker follows a clean, layered architecture with clear separation of concerns.

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  Screens, Widgets, Animations      │
└────────────────┬────────────────────┘
                 │
┌─────────────────▼────────────────────┐
│  State Management Layer (Provider)   │
│  HabitProvider - Single Source of Truth
└────────────────┬────────────────────┘
                 │
┌─────────────────▼────────────────────┐
│    Domain Layer (Business Logic)     │
│  Models, Validators, Use Cases      │
└────────────────┬────────────────────┘
                 │
┌─────────────────▼────────────────────┐
│      Services Layer                 │
│  Storage, Security, Connectivity    │
└────────────────┬────────────────────┘
                 │
┌─────────────────▼────────────────────┐
│    Data Layer (Storage & API)       │
│  Hive, Firebase, Secure Storage    │
└─────────────────────────────────────┘
```

---

## Design Patterns

### 1. **Model-View-Controller (MVC)**
- **Model**: `Habit` class contains business logic
- **View**: Screens and widgets render UI
- **Controller**: `HabitProvider` manages state

### 2. **Provider Pattern (State Management)**
```dart
// Single source of truth
class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;
  
  // Expose state via getters
  List<Habit> get habits => _habits;
  
  // Trigger UI updates
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    notifyListeners(); // Rebuilds listeners
  }
}
```

### 3. **Repository Pattern (Data Access)**
```dart
// StorageService abstracts Hive + Encryption
class StorageService {
  Future<void> saveHabit(Habit habit) async {
    // Encryption happens here
  }
  
  Future<List<Habit>> getAllHabits() async {
    // Decryption happens here
  }
}
```

### 4. **Singleton Pattern (Services)**
```dart
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  
  factory SecurityService() => _instance;
  SecurityService._internal();
}
```

### 5. **Factory Pattern (Habit Creation)**
```dart
Habit.fromJson(json) // Factory constructor
habit.toJson()       // Serialization
habit.copyWith(...)  // Immutable updates
```

---

## Layer Breakdown

### 📱 Presentation Layer

**Files**: `screens/`, `widgets/`

**Responsibilities**:
- Render UI components
- Handle user interactions
- Display data from Provider
- Show/hide loading states

**Key Components**:
```dart
HomeScreen              // Main screen with navigation
AddEditHabitScreen      // Form for habit creation
StatsScreen            // Analytics dashboard
SettingsScreen         // App configuration
HabitCard              // Reusable habit display widget
```

### 🔄 State Management Layer

**File**: `providers/habit_provider.dart`

**Responsibilities**:
- Single source of truth for app state
- Coordinate between UI and services
- Handle business logic
- Notify listeners of changes

**Key Methods**:
```dart
initialize()                  // Load initial data
addHabit(Habit)              // Create new habit
updateHabit(Habit)           // Update existing
toggleHabitCompletion(id)    // Mark as done
getStatistics()              // Calculate stats
syncWithFirebase()           // Cloud sync
```

### 🧠 Domain Layer

**Files**: `models/`, `utils/validators.dart`

**Responsibilities**:
- Define data structures
- Implement business logic
- Validate inputs
- Calculate computed values

**Key Components**:
```dart
Habit                 // Core data model
Validators           // Input validation
Constants            // App-wide values
Helpers              // Utility functions
```

**Habit Model Features**:
```dart
class Habit {
  // Computed properties
  double get completionPercentage
  bool isCompletedToday()
  bool isCompletedOnDate(date)
  
  // Methods
  addCompletion()
  removeCompletion()
  _calculateStreak()
  
  // Serialization
  toJson()
  fromJson()
  copyWith()
}
```

### 🔧 Services Layer

**Files**: `services/`

**Responsibilities**:
- Implement specific features
- Abstract external dependencies
- Handle errors gracefully

**Key Services**:

1. **StorageService** (Data Persistence)
   - Save/load habits with encryption
   - Export/import functionality
   - Local database management

2. **SecurityService** (Encryption)
   - AES-256 encryption/decryption
   - Secure key generation and storage
   - JSON encryption support

3. **FirebaseService** (Cloud Sync)
   - Authentication
   - Cloud data sync
   - Real-time updates

4. **ConnectivityService** (Network)
   - Monitor connection status
   - Offline/online detection
   - Sync triggering

### 💾 Data Layer

**Technologies**:
- **Hive**: Local encrypted database
- **firebase_core**: Cloud backend
- **flutter_secure_storage**: Secure key storage

**Data Flow**:
```
App → Provider → StorageService → SecurityService → Hive
                                 → FirebaseService → Firebase
```

---

## Data Flow Example: Creating a Habit

```
User taps "+" button
         ↓
AddEditHabitScreen shows form
         ↓
User fills form and taps "Create"
         ↓
Form validation (Validators.validateHabitName)
         ↓
HabitProvider.addHabit(habit)
         ↓
StorageService.saveHabit(habit)
         ↓
SecurityService.encryptJson(habit)
         ↓
Hive stores encrypted data
         ↓
If online: FirebaseService.saveHabit(habit)
         ↓
Provider notifyListeners()
         ↓
UI rebuilds with new habit in list
```

---

## State Management Deep Dive

### Provider vs Local State

**Use Provider for**:
- Global app state (habit list)
- User preferences
- Authentication state
- Data that multiple screens need

**Use Local State for**:
- Form input during editing
- UI animations
- Temporary UI state
- Single screen concerns

### Example: HabitProvider Usage

```dart
// Listen to all changes
Consumer<HabitProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.habits.length,
      itemBuilder: (context, index) {
        return HabitCard(habit: provider.habits[index]);
      },
    );
  },
);

// Listen to specific property
selector: (context, provider) => provider.habits.length,

// Read without listening
context.read<HabitProvider>().addHabit(habit);
```

---

## Offline Support Architecture

```
Action triggered (create, update, delete)
         ↓
Save to local storage immediately
         ↓
UI updates from local data (instant feedback)
         ↓
If online: Sync to Firebase in background
         ↓
If offline: Queue changes, sync when reconnected
         ↓
ConnectivityService monitors connection
         ↓
Auto-sync when connection restored
```

---

## Error Handling Strategy

### Service-Level Errors
```dart
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
}

try {
  await storageService.saveHabit(habit);
} on StorageException catch (e) {
  provider._setError(e.message);
}
```

### UI-Level Error Display
```dart
if (habitProvider.error != null) {
  showSnackBar(context, habitProvider.error!);
}
```

### Input Validation
```dart
String? error = Validators.validateHabitName(input);
if (error != null) {
  // Show error to user
}
```

---

## Testing Architecture

### Unit Tests Structure
```
test/
├── models/
│   ├── habit_test.dart          # Model logic tests
│   └── validators_test.dart     # Validation tests
├── services/
│   └── [service tests]
└── widgets/
    └── habit_widgets_test.dart  # Widget tests
```

### Test Patterns

```dart
// Model tests
testWidgets('habit.addCompletion increments streak') {
  final habit = Habit(...);
  final updated = habit.addCompletion();
  expect(updated.currentStreak, greaterThan(habit.currentStreak));
}

// Widget tests
testWidgets('HabitCard displays habit name') {
  await tester.pumpWidget(
    HabitCard(habit: testHabit, ...)
  );
  expect(find.text('Morning Exercise'), findsOneWidget);
}
```

---

## Performance Optimization

### Rendering
- ✅ Use `const` constructors where possible
- ✅ Lazy load lists with `ListView.builder`
- ✅ Avoid unnecessary rebuilds with `selector`
- ✅ Cache computed values

### Storage
- ✅ Encrypt only when necessary
- ✅ Batch database operations
- ✅ Use indexes for queries
- ✅ Clean up old data periodically

### Network
- ✅ Batch Firebase writes
- ✅ Cache frequently accessed data
- ✅ Use streams for real-time updates
- ✅ Implement exponential backoff retry

---

## Security Architecture

```
User Input
    ↓
Form Validation (Validators)
    ↓
Sanitization
    ↓
AES-256 Encryption (SecurityService)
    ↓
Secure Storage (flutter_secure_storage)
    ↓
Local Hive Database
    ↓
(Optional) Firebase HTTPS
```

**Key Features**:
- ✅ Encryption at rest
- ✅ Secure key storage
- ✅ Input validation
- ✅ Error handling

---

## Scalability Considerations

### If Adding New Features:

1. **New Screen**: Create in `screens/`, add route to navigation
2. **New Service**: Create in `services/`, inject into Provider
3. **New Model**: Create in `models/`, add serialization methods
4. **New Business Logic**: Add to Provider or create dedicated service

### Growth Path:
- **Phase 1**: Local storage only (current)
- **Phase 2**: Add Firebase sync
- **Phase 3**: Add user accounts
- **Phase 4**: Add social features
- **Phase 5**: Add advanced analytics

---

## Best Practices Applied

✅ **SOLID Principles**
- Single Responsibility: Each class has one job
- Open/Closed: Easy to extend, hard to break
- Liskov Substitution: Services are interchangeable
- Interface Segregation: Minimal interfaces
- Dependency Inversion: Depend on abstractions

✅ **Clean Code**
- Descriptive naming
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)
- Comments for "why", not "what"

✅ **Dart Best Practices**
- Null safety throughout
- Const constructors for immutability
- Proper async/await usage
- Error handling everywhere

---

**This architecture ensures scalability, maintainability, and testability!**
