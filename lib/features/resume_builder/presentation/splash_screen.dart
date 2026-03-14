import 'package:flutter/material.dart';
import 'home_screen.dart'; // ⬅️ Yahan HomeScreen import karein

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2 second baad automatically next screen par jaye
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        // ⬅️ ASAL FIX: Yahan ab HomeScreen() aayega
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.description, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text('CV Forge Pro', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}