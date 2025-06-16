// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/auth/sign_up.dart';
import 'package:utmthrift_mobile/views/auth/sign_in.dart';

//test
//import 'package:utmthrift_mobile/views/test-cors.dart'; 

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-Screen Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/welcome_page.jpg",
              fit: BoxFit.cover, // Covers the entire screen
            ),
          ),

          // Curved Bottom Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 250, 
              decoration: const BoxDecoration(
                color: Color(0xFFFFFCF4), // Base color
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(50), // Curved effect
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min, // Prevent overflow by limiting height
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome Text
                  const Text(
                    "Welcome To,",
                    style: TextStyle(
                      fontFamily: "Merienda",
                      fontSize: 24.0,
                      color: Color(0xFF9F4F5D),
                    ),
                    textAlign: TextAlign.center, 
                  ),
                  const Text(
                    "UTM THRIFT",
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBB0000), 
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () {
                        // Navigate to Sign In
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Color(0xFF9F4F5D)),
                      ),
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(fontSize: 18, color: Color(0xFF9F4F5D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Sign Up
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9F4F5D), // Button color
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "SIGN UP",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                   const SizedBox(height: 10),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}