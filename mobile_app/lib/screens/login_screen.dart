import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacementNamed(context, '/babyform');
      }
    } catch (e) {
      print('Google login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _handleEmailLogin() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(  
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacementNamed(context, '/babyform');
    } catch (e) {
      print('Email login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(  
        SnackBar(content: Text('Email login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailRegister() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(  
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('Registration Successful. You Can Login!')),
      );
    } catch (e) {
      print('Register error: $e');
      ScaffoldMessenger.of(context).showSnackBar(  
        SnackBar(content: Text('Registration Failed: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(  
          padding: const EdgeInsets.all(32.0),
          child: _isLoading
            ? const CircularProgressIndicator(color: Colors.pinkAccent)
            : SingleChildScrollView(
              child: Column(  
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(  
                  "Login with NeoMama",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(  
                  controller: _emailController,
                  decoration: const InputDecoration(  
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(  
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(  
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(  
                  onPressed: _handleEmailLogin,
                  child: const Text('Login with Email'),
                ),
                TextButton(  
                  onPressed: _handleEmailRegister,
                  child: const Text('register'),
                ),
                const Divider(height: 40),
                ElevatedButton.icon(  
                  onPressed: _handleGoogleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in With Google'),
                  style: ElevatedButton.styleFrom(  
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(  
                      horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(  
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
            