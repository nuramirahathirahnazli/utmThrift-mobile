// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/signin_viewmodel.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signinViewModel = Provider.of<SigninViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.base, // Using base cream color
      appBar: AppBar(
        title: const Text("Sign In", 
               style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: AppColors.base, // Cream text on maroon
               )),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.color2, // Using color2 (9F4F5D) for app bar
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.base),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Text
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color2, // Using color2 (9F4F5D)
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to your UTMThrift account",
                    style: TextStyle(
                      color: AppColors.color10.withOpacity(0.6), // Black with opacity
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: AppColors.color2),
                      prefixIcon: const Icon(Icons.email, color: AppColors.color2),
                      filled: true,
                      fillColor: AppColors.color12, // Light yellow background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.color2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.color8),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: AppColors.color2),
                      prefixIcon: const Icon(Icons.lock, color: AppColors.color2),
                      filled: true,
                      fillColor: AppColors.color12, // Light yellow background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.color2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.color8),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "Password is required" : null,
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  signinViewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.color2),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.color2, // Maroon button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                String? message = await signinViewModel.loginUser(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  context,
                                );

                                if (message == "Login successful!") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message ?? "An error occurred"),
                                      backgroundColor: AppColors.color13, // Green for success
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              "SIGN IN",
                              style: TextStyle(
                                color: AppColors.base, // Cream text
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),

                  // Sign Up Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/sign_up');
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.color10.withOpacity(0.6), // Black with opacity
                          ),
                          children: const [
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                color: AppColors.color2, // Maroon
                                fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}