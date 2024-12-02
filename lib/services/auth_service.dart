import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';

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

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _currentUser;

  Future<UserCredential?> signIn(String email, String password) async {
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

  Future<UserCredential?> register(String email, String password) async {
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
