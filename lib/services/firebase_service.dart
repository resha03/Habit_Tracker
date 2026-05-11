import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

class FirebaseException implements Exception {
  final String message;
  FirebaseException(this.message);

  @override
  String toString() => 'FirebaseException: $message';
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  late Box _authBox;

  /// Initialize Firebase (disabled on web to avoid compatibility issues)
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _authBox = await Hive.openBox(AppConstants.userBox);
      print('[Firebase] Service initialized with mock auth');
    } catch (e) {
      print('[Firebase] Initialization error: $e');
    }
  }

  /// Sign up with email and password
  Future<void> signUp(String email, String password) async {
    try {
      if (password.length < 6) {
        throw FirebaseException('Password must be at least 6 characters');
      }
      final currentUser = _authBox.get('current_user') as Map<String, dynamic>?;
      if (currentUser != null) {
        throw FirebaseException('User already registered');
      }
      final uid = const Uuid().v4();
      _authBox.put('current_user', {'uid': uid, 'email': email});
      print('[Firebase] Mock sign up success for $email');
    } catch (e) {
      throw FirebaseException(e.toString());
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      if (password.length < 6) {
        throw FirebaseException('Invalid credentials');
      }
      final currentUser = _authBox.get('current_user') as Map<String, dynamic>?;
      if (currentUser == null || currentUser['email'] != email) {
        throw FirebaseException('Invalid email or password');
      }
      print('[Firebase] Mock sign in success for $email');
    } catch (e) {
      throw FirebaseException(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authBox.delete('current_user');
      print('[Firebase] Mock sign out success');
    } catch (e) {
      throw FirebaseException('Sign out failed: $e');
    }
  }

  /// Get current user
  Map<String, dynamic>? getCurrentUser() {
    return _authBox.get('current_user') as Map<String, dynamic>?;
  }

  /// Get auth state changes stream
  Stream<Map<String, dynamic>?> getAuthStateChanges() {
    return _authBox.watch(key: 'current_user').map((boxEvent) => boxEvent.value as Map<String, dynamic>?);
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    print('[Firebase] Mock reset password email sent to $email');
  }

  /// Save habit to cloud
  Future<void> saveHabit(String userId, Map<String, dynamic> habit) async {
    if (kIsWeb) {
      print('[Firebase] Habit save skipped on web');
      return;
    }
  }

  /// Get habits from cloud
  Future<List<Map<String, dynamic>>> getHabits(String userId) async {
    if (kIsWeb) {
      print('[Firebase] Habit retrieval skipped on web');
      return [];
    }
    return [];
  }

  /// Get habits stream (real-time updates)
  Stream<List<Map<String, dynamic>>> getHabitsStream(String userId) {
    return Stream.value([]);
  }

  /// Delete habit from cloud
  Future<void> deleteHabit(String userId, String habitId) async {
    if (kIsWeb) {
      print('[Firebase] Habit delete skipped on web');
      return;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    if (kIsWeb) {
      print('[Firebase] Profile update skipped on web');
      return;
    }
  }
}
