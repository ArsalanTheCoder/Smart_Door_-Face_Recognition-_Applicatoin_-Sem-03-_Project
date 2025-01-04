import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> registerAtFirebase() async {
    String userName = nameController.text.trim();
    String userEmail = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (userName.isEmpty || userEmail.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all the fields!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.red,
      );
    } else if (password != confirmPassword) {
      Fluttertoast.showToast(
        msg: "Passwords do not match!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.red,
      );
    } else {
      try {
        await saveDataUsingSharedPreference(userName, userEmail);
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: userEmail, password: password);
        if (userCredential != null) {
          Fluttertoast.showToast(
            msg: "Account Created Successfully.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.white,
            textColor: Colors.green,
          );
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: "${e.code.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.red,
        );
      }
    }
  }

  Future<void> saveDataUsingSharedPreference(String userName, String userEmail) async {
    final preference = await SharedPreferences.getInstance();
    preference.setString('userName', userName);
    preference.setString('userEmail', userEmail);
  }

  List<Color> _circleColors = [
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.cyanAccent,
    Colors.orangeAccent,
  ];
  int _circleColorIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _circleColorIndex = (_circleColorIndex + 1) % _circleColors.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(designIndex: _circleColorIndex),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 320,
                  height: 450,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.withOpacity(0.2), Colors.amber.withOpacity(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildTextField(nameController, "Name", Icons.person),
                          buildTextField(emailController, "Email", Icons.email),
                          buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
                          buildTextField(confirmPasswordController, "Confirm Password", Icons.lock_outline, obscureText: true),
                          const SizedBox(height: 20),
                        ElevatedButton(onPressed: registerAtFirebase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          // const SizedBox(height: 10),
                          // // OutlinedButton.icon(
                          // //   onPressed: () {
                          // //     // Implement Google Sign-In
                          // //   },
                          // //   icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                          // //   label: const Text(
                          // //     "Register with Google",
                          // //     style: TextStyle(color: Colors.red),
                          // //   ),
                          // //   style: OutlinedButton.styleFrom(
                          // //     side: BorderSide(color: Colors.red),
                          // //     shape: RoundedRectangleBorder(
                          // //       borderRadius: BorderRadius.circular(20),
                          // //     ),
                          // //   ),
                          // // ),
                          // const SizedBox(height: 20),
                          // GestureDetector(
                          //   onTap: () {
                          //     Navigator.pop(context);
                          //   },
                          //   child: const Text(
                          //     "Already have an account? Log In",
                          //     style: TextStyle(color: Colors.pink, fontSize: 12),
                          //   ),
                          // ),
                          // SizedBox(height: 7),
                          // Container(
                          //   height: 2,
                          //   width: 180,
                          //   color: Colors.yellow,
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          buildGlowingCircles(),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget buildGlowingCircles() {
    return Stack(
      children: [
        Positioned(top: 30, left: 30, child: _GlowingCircle(color: _circleColors[_circleColorIndex])),
        Positioned(top: 30, right: 30, child: _GlowingCircle(color: _circleColors[_circleColorIndex])),
        Positioned(bottom: 30, left: 30, child: _GlowingCircle(color: _circleColors[_circleColorIndex])),
        Positioned(bottom: 30, right: 30, child: _GlowingCircle(color: _circleColors[_circleColorIndex])),
      ],
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  final int designIndex;

  const AnimatedBackground({required this.designIndex});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.grey.withOpacity(0.1)); // Replace with custom background
  }
}

class _GlowingCircle extends StatelessWidget {
  final Color color;

  const _GlowingCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.6),
        boxShadow: [
          BoxShadow(color: color, blurRadius: 15, spreadRadius: 5),
        ],
      ),
    );
  }
}
