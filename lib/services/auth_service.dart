import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.currentUser != null;

  
  
  

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}




class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException({
    required this.code,
    required this.message,
  });

  factory AuthException.fromFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException(
          code: 'user-not-found',
          message: 'No user found with this email.',
        );
      case 'wrong-password':
        return const AuthException(
          code: 'wrong-password',
          message: 'Incorrect password.',
        );
      case 'email-already-in-use':
        return const AuthException(
          code: 'email-already-in-use',
          message: 'This email is already registered.',
        );
      case 'invalid-email':
        return const AuthException(
          code: 'invalid-email',
          message: 'Invalid email address.',
        );
      case 'weak-password':
        return const AuthException(
          code: 'weak-password',
          message: 'Password is too weak.',
        );
      default:
        return AuthException(
          code: e.code,
          message: e.message ?? 'Authentication error.',
        );
    }
  }

  @override
  String toString() => message;
}
