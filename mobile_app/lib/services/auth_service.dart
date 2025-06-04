import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  
    // Sign in with email and password
    Future<User?> signInWithGoogle() async {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled the sign-in
      
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      return userCred.user;
    }

    Future<User?> signUp(String email, String password) async {
      try {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return result.user;
      } catch (e) {
        print("SignUp Error: $e");
        return null;
      }
    }
  
    // Register with email and password
    Future<User?> signIn(String email, String password) async {
      try {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return result.user;
      } catch (e) {
        print("SignIn Error: $e");
        return null;
      }
    }
  
    // Sign out
    Future<void> signOut() async {
      await _auth.signOut();
    }

    // Get current user
    Stream<User?> get user => _auth.authStateChanges();
}
