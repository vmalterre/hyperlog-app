import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hyperlog/services/error_service.dart';
import 'package:hyperlog/services/integrations/auth_error_codes.dart';

/// Result of a sign-in attempt. Either succeeds with a User,
/// or requires MFA resolution.
class SignInResult {
  final User? user;
  final MultiFactorResolver? mfaResolver;
  /// Email from the sign-in attempt (needed for recovery code flow during MFA).
  final String? email;

  SignInResult({this.user, this.mfaResolver, this.email});

  bool get requiresMfa => mfaResolver != null;
}

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

  // Sign In — returns SignInResult to handle MFA challenge
  Future<SignInResult> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return SignInResult(user: userCredential.user);

    } on FirebaseAuthMultiFactorException catch (e) {
      return SignInResult(mfaResolver: e.resolver);

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

  // Sign In with Google — returns SignInResult to handle MFA challenge
  Future<SignInResult> signInWithGoogle() async {
    String? googleEmail;
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        return SignInResult();
      }
      googleEmail = googleUser.email;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return SignInResult(user: userCredential.user);

    } on FirebaseAuthMultiFactorException catch (e) {
      return SignInResult(mfaResolver: e.resolver, email: googleEmail);

    } on FirebaseAuthException catch (e) {
      if (!AuthErrorCodes.ignoreErrorCodes.contains(e.code)) {
        ErrorService().reporter.reportError(e, StackTrace.current,
            message: 'Error during Google sign in');
      }
      return Future.error(e.message ?? "An unknown error occurred.");
    } catch (e, stackTrace) {
      ErrorService().reporter.reportError(e, stackTrace,
          message: 'Error during Google sign in');
      return Future.error("Google sign-in failed. Please try again.");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
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

  // Account Management

  /// Returns list of provider IDs linked to the current user (e.g. 'password', 'google.com')
  List<String> getLinkedProviders() {
    final user = _auth.currentUser;
    if (user == null) return [];
    return user.providerData.map((info) => info.providerId).toList();
  }

  /// Reauthenticate with email/password (required before sensitive operations)
  Future<void> reauthenticateWithPassword(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  /// Reauthenticate with Google (required before sensitive operations)
  Future<void> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Update password (requires prior reauthentication)
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await user.updatePassword(newPassword);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Link email/password provider to current account (for Google-only users)
  Future<void> linkEmailPassword(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.linkWithCredential(credential);
  }

  /// Link Google provider to current account
  Future<void> linkGoogle() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.linkWithCredential(credential);
  }

  /// Unlink a provider from the current account (e.g. 'google.com')
  Future<void> unlinkProvider(String providerId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await user.unlink(providerId);
  }

  /// Delete the Firebase Auth account (requires prior reauthentication)
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await GoogleSignIn().signOut();
    await user.delete();
  }
}
