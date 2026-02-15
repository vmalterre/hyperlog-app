import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing Multi-Factor Authentication (TOTP and SMS)
/// via Firebase Auth's native MFA support.
class MfaService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Factor ID constants (matching Firebase Auth factor types)
  static const String totpFactorId = 'totp';
  static const String phoneFactorId = 'phone';

  // ==========================================
  // TOTP Enrollment
  // ==========================================

  /// Start TOTP enrollment: generates a secret and returns the TOTP secret
  /// object containing the QR code URI and manual entry key.
  Future<TotpSecret> startTotpEnrollment() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final session = await user.multiFactor.getSession();
    final secret = await TotpMultiFactorGenerator.generateSecret(session);
    return secret;
  }

  /// Finalize TOTP enrollment with the verification code from the
  /// authenticator app.
  Future<void> finalizeTotpEnrollment(
    TotpSecret secret,
    String verificationCode,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final assertion = await TotpMultiFactorGenerator.getAssertionForEnrollment(
      secret,
      verificationCode,
    );
    await user.multiFactor.enroll(assertion, displayName: 'Authenticator App');
  }

  // ==========================================
  // SMS Enrollment
  // ==========================================

  /// Start SMS enrollment: sends a verification code to the phone number.
  /// Returns the verification ID needed to complete enrollment.
  Future<String> startSmsEnrollment(String phoneNumber) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final session = await user.multiFactor.getSession();

    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      multiFactorSession: session,
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(e.message ?? 'Phone verification failed'),
          );
        }
      },
      codeSent: (id, _) {
        if (!completer.isCompleted) {
          completer.complete(id);
        }
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception('Failed to send verification code'),
    );
  }

  /// Finalize SMS enrollment with the SMS code received.
  Future<void> finalizeSmsEnrollment(
    String verificationId,
    String smsCode,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
    await user.multiFactor.enroll(assertion, displayName: 'SMS');
  }

  // ==========================================
  // MFA Challenge (Login)
  // ==========================================

  /// Resolve a TOTP MFA challenge during sign-in.
  Future<UserCredential> resolveTotpChallenge(
    MultiFactorResolver resolver,
    String verificationCode,
  ) async {
    // Find the TOTP factor's enrollment ID from the hints
    final totpHint = resolver.hints.firstWhere(
      (h) => h.factorId == totpFactorId,
    );
    final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
      totpHint.uid,
      verificationCode,
    );
    return resolver.resolveSignIn(assertion);
  }

  /// Start SMS challenge: sends the SMS code for the selected factor.
  /// Returns the verification ID.
  Future<String> startSmsChallenge(
    MultiFactorResolver resolver,
    MultiFactorInfo smsFactorInfo,
  ) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      multiFactorSession: resolver.session,
      multiFactorInfo: smsFactorInfo as PhoneMultiFactorInfo,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(e.message ?? 'Phone verification failed'),
          );
        }
      },
      codeSent: (id, _) {
        if (!completer.isCompleted) {
          completer.complete(id);
        }
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception('Failed to send verification code'),
    );
  }

  /// Resolve an SMS MFA challenge during sign-in.
  Future<UserCredential> resolveSmsChallenge(
    MultiFactorResolver resolver,
    String verificationId,
    String smsCode,
  ) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
    return resolver.resolveSignIn(assertion);
  }

  // ==========================================
  // Factor Management
  // ==========================================

  /// Get all enrolled MFA factors for the current user.
  Future<List<MultiFactorInfo>> getEnrolledFactors() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    return await user.multiFactor.getEnrolledFactors();
  }

  /// Check if the user has any MFA factors enrolled.
  Future<bool> hasMfaEnabled() async {
    final factors = await getEnrolledFactors();
    return factors.isNotEmpty;
  }

  /// Check if TOTP is enrolled.
  Future<bool> hasTotpEnrolled() async {
    final factors = await getEnrolledFactors();
    return factors.any((f) => f.factorId == totpFactorId);
  }

  /// Check if SMS is enrolled.
  Future<bool> hasSmsEnrolled() async {
    final factors = await getEnrolledFactors();
    return factors.any((f) => f.factorId == phoneFactorId);
  }

  /// Unenroll a specific MFA factor.
  Future<void> unenrollFactor(MultiFactorInfo factorInfo) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await user.multiFactor.unenroll(multiFactorInfo: factorInfo);
  }
}
