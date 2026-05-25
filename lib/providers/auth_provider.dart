import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream untuk pantau status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    notifyListeners();
  }

  // Register
  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
