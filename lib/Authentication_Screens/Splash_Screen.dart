import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'Welcome_Screen.dart';

class CombinedSplashScreen extends StatefulWidget {
  @override
  _CombinedSplashScreenState createState() => _CombinedSplashScreenState();
}


//====================================================
//========   SPLASH SCREEN GUI     ==================
//====================================================
class _CombinedSplashScreenState extends State<CombinedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));

    _controller.forward();

    // Navigate to another action or screen after 4 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) =>WelcomeScreen() ));
      print("Splash Screen Completed");
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
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Colors.blue.shade900,
                  // Colors.blue.shade700,
                  // Colors.purple.shade500,
                  Colors.black,
                  Colors.black,
                  Colors.white,


                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Moving stars or particles
          Positioned.fill(
            child: CustomPaint(
              painter: StarPainter(),
            ),
          ),
          // Center content with animations
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // App Name
                Text(
                  'Smart Door Camera',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                // Tagline
                Text(
                  'Secure Your World',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    final random = Random();

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
