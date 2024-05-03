import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Sign-up successful
    } catch (e) {
      print('Error signing up with email and password: $e');
      return false; // Sign-up failed
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Login successful
    } catch (e) {
      print('Error signing in with email and password: $e');
      return false; // Login failed
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
