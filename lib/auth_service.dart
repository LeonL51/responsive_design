import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  // Keep instance private only for this class to handle Auth
  // Singleton.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign In Method
  Future<User?> signIn({
    // Named, not positional parameters
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors (Upper Level requirement)
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided');
      } else {
        throw Exception(e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      throw Exception('System error: $e');
    }
  }

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('ACCOUNT_EXISTS'); // special case
      }
      if (e.code == 'invalid-email') {
        throw Exception('Invalid email address.');
      }
      if (e.code == 'weak-password') {
        throw Exception('Password is too weak.');
      }
      throw Exception(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw Exception('System error: $e');
    }
  }

  // Sign Out Method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
