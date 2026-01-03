import 'package:firebase_auth/firebase_auth.dart';
import 'package:hyperlog/services/error_service.dart';
import 'package:hyperlog/services/integrations/auth_error_codes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch  (e) {
      //Some error codes don't have to be reported to crashlytics, just to the user.
      if (!AuthErrorCodes.ignoreErrorCodes.contains(e.code)) {
        Map<String, dynamic> metadata = {
          'email': email,
          'passwordLength': password.length,
        };
        ErrorService().reporter.reportError(e, StackTrace.current, message: 'Error during sign up', metadata: metadata);
      }

      return Future.error(e.message ?? "An unknown error occurred.");
    }
  }

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;

    } on FirebaseAuthException catch  (e) {

      //Some error codes don't have to be reported to crashlytics, just to the user.
      if (!AuthErrorCodes.ignoreErrorCodes.contains(e.code)) {
        Map<String, dynamic> metadata = {
          'email': email,
          'passwordLength': password.length,
        };
        ErrorService().reporter.reportError(e, StackTrace.current, message: 'Error during sign in', metadata: metadata);
      }
      
      return Future.error(e.message ?? "An unknown error occurred.");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //Check login status
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}
