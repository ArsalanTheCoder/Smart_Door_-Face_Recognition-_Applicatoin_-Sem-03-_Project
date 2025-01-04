import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Admin_Side_Screens/AddViewRemove_Member_In_Database.dart';
import 'User_Side_Screens/Recognize_Member_From_Database.dart';

late String? UserEmail, UserPassword;

class Homescreenofdoor extends StatefulWidget {
  final String? userEmail, userPassword;
  const Homescreenofdoor({super.key, this.userEmail, this.userPassword});

  @override
  State<Homescreenofdoor> createState() => _HomescreenofdoorState();
}

class _HomescreenofdoorState extends State<Homescreenofdoor> {
  @override
  void initState() {
    super.initState();
    // Assigning the passed userEmail and userPassword to global variables
    UserEmail = widget.userEmail;
    UserPassword = widget.userPassword;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Function to show the password dialog
  void _showPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Admin Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String enteredPassword = passwordController.text.trim();
                if(enteredPassword.isEmpty){
                  Fluttertoast.showToast(
                    msg: "Please enter admin password!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.greenAccent,
                    textColor: Colors.white,
                  );
                }
                // Validate password
               else if (enteredPassword== UserPassword) {
                  Fluttertoast.showToast(
                    msg: "Admin Open Successful!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.greenAccent,
                    textColor: Colors.white,
                  );
                  // Navigate to Admin screen
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddviewremoveMemberInDatabase(),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Password Incorrect!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.greenAccent,
                    textColor: Colors.white,
                  );
                  // Show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect Password!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Smart Door App',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
          ),
          centerTitle: true,
          backgroundColor: Colors.indigo.shade700,
        ),
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.indigo.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Main Content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Admin Section
                    GestureDetector(
                      onTap: () {
                        _showPasswordDialog(context); // Show the password dialog
                      },
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          height: 150,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [Colors.redAccent, Colors.pinkAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.admin_panel_settings,
                                  size: 50, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                'Admin',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Manage permanent members',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // User Section
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecognizeMemberFromDatabase(
                                userEmail: UserEmail),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          height: 150,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [Colors.tealAccent, Colors.green],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 50, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                'User',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Recognize members effortlessly',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
