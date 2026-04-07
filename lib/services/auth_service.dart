import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final auth = FirebaseAuth.instance;

  Future login(String email, String pass) async {
    await auth.signInWithEmailAndPassword(email: email, password: pass);
  }

  Future register(String email, String pass) async {
    await auth.createUserWithEmailAndPassword(email: email, password: pass);
  }

  void logout() async {
    await auth.signOut();
  }
}