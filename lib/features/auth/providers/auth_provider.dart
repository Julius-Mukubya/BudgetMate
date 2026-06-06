import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Provider for the FirebaseAuth instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider for the GoogleSignIn instance.
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

/// Provider that exposes the current auth state.
///
/// Emits the current User when authenticated, or null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Provider for the current user's UID.
///
/// Returns null when the user is not authenticated.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

/// Auth service that handles email/password and Google sign-in.
final authServiceProvider = Provider<AuthService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthService(auth: auth, googleSignIn: googleSignIn);
});

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _googleSignIn = googleSignIn;

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Create a new account with email and password.
  Future<UserCredential> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Sign in with Google.
  ///
  /// This requires:
  /// 1. SHA-1 certificate fingerprint added to Firebase Console (Android app settings)
  /// 2. Google Sign-In enabled in Firebase Console Authentication
  Future<UserCredential> signInWithGoogle() async {
    // Trigger Google sign-in flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // User cancelled the sign-in flow
      throw FirebaseAuthException(
        code: 'canceled',
        message: 'Google sign-in was cancelled.',
      );
    }

    // Get authentication credentials
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await _auth.signInWithCredential(credential);
  }

  /// Sign out from both Google and Firebase.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}