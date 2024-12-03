import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';

/// Service for handling Firebase Authentication.
/// 
/// Provides:
/// - User authentication state management
/// - Sign in/out functionality
/// - User profile management
/// - Auth state streams
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository;
  User? _currentUser;

  AuthService(this._userRepository) {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Current authenticated user, null if not signed in
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in user with email and password
  /// 
  /// Throws [FirebaseAuthException] if:
  /// - Invalid email
  /// - Wrong password
  /// - User not found
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _currentUser = credential.user;
      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  /// Creates new user account with email and password
  /// 
  /// Throws [FirebaseAuthException] if:
  /// - Email already in use
  /// - Weak password
  /// - Invalid email
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      notifyListeners();
      // Create user profile
      final user = AppUser(
        id: credential.user!.uid,
        email: email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _userRepository.create(user);
      notifyListeners();
      _currentUser = credential.user;
      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
