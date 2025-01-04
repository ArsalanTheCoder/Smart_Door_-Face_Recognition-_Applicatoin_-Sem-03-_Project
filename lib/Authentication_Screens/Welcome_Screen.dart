import 'package:flutter/material.dart';
import 'Login_Screen.dart';

class WelcomeScreen extends StatelessWidget {


//====================================================
//========   WELCOME SCREEN GUI     ==================
//====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: 850,
            width: 380,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_image.jpg'), // My background image here
                //  image: AssetImage('assets/WelcomeBackground.jpg'),
                fit: BoxFit.cover, // Adjust the fit as needed (e.g., BoxFit.fill)
              ),
            ),
          ),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             // Welcome text
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 50),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 550),
              // Button with icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the button
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Container(
                        width: 300, // Adjusted width for extra space
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(3, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between text and icon
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0), // Padding for left space
                              child: Text(
                                'Let\'s Start',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0), // Padding for right space
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 30, // Adjust the icon size as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
