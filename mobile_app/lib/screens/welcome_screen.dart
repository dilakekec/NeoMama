import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    }); 
  }
  

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(  
              'Welcome Mother',
              style: TextStyle(  
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cursive',
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Let's care, grow and glow together.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height:40),
            CircularProgressIndicator(color: Colors.pinkAccent),
          ],
        ),
      ),     
    );      
  }
}