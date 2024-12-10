import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'todo_list_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
    // Check the user's authentication status after the animation finishes
    Future.delayed(const Duration(seconds: 5), () {
      User? user = FirebaseAuth.instance.currentUser;
      // Navigate based on user login status
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user == null ? LoginScreen() : ToDoListScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Logo with animation
              ScaleTransition(
                scale: _animation,
                child: const Icon(
                  Icons.check_circle,
                  size: 100, // Fixed size
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20), // Fixed spacing
              // App Name
              FadeTransition(
                opacity: _animation,
                child: const Text(
                  "My ToDo",
                  style: TextStyle(
                    fontSize: 32, // Fixed font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10), // Fixed spacing
              // Tagline
              FadeTransition(
                opacity: _animation,
                child: Text(
                  "Stay organized. Get things done.",
                  style: TextStyle(
                    fontSize: 16, // Fixed font size
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30), // Add spacing between tagline and loader
              // Loading Indicator
              const CircularProgressIndicator(
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
