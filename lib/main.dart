import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the sign-up pages
import 'Station Owner/station_owner_signup.dart';
import 'Car Owner/car_owner_signup.dart';
import 'Car Owner/car_owner_login.dart'; // Import the Car Owner Login Page
import 'Station Owner/station_owner_login.dart'; // Import the Station Owner Login Page
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  // Show the dialog to select user type
  void _showUserTypeDialog(BuildContext context, bool isSignUp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select User Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Car Owner Option
              ListTile(
                title: Text('Car Owner'),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  if (isSignUp) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CarOwnerSignUpScreen()), // Redirect to Car Owner SignUp
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CarOwnerLoginScreen()), // Redirect to Car Owner Login
                    );
                  }
                },
              ),
              // Station Owner Option
              ListTile(
                title: Text('Station Owner'),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  if (isSignUp) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StationOwnerSignUpScreen()), // Redirect to Station Owner SignUp
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StationOwnerLoginScreen()), // Redirect to Station Owner Login
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // 40% for logo and title
          Container(
            height: screenHeight * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.electric_car, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'EvApp',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 60% for welcome text and buttons
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome!',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Create Account Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () => _showUserTypeDialog(context, true), // Show dialog for SignUp
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Login Button with Darker Border
                  OutlinedButton(
                    onPressed: () => _showUserTypeDialog(context, false), // Show dialog for Login
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                      side: BorderSide(color: Colors.black, width: 2), // Darker border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
