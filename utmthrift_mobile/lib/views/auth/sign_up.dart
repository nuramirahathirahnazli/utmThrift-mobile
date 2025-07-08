// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/signup_viewmodel.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _matricController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final signupViewModel = Provider.of<SignupViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.base, // Using your base color
      appBar: AppBar(
        title: const Text("Sign Up", 
               style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Colors.white,
               )),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.color2, // Using your maroon color
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: const TextStyle(color: AppColors.color2),
                  prefixIcon: const Icon(Icons.person, color: AppColors.color2),
                  filled: true,
                  fillColor: AppColors.color12, // Light yellow background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16.0),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: AppColors.color2),
                  prefixIcon: const Icon(Icons.email, color: AppColors.color2),
                  filled: true,
                  fillColor: AppColors.color12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Email is required";
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@(graduate\.utm\.my|utm\.my)$")
                      .hasMatch(value)) {
                    return "Only UTM emails (@graduate.utm.my / @utm.my) are allowed";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: AppColors.color2),
                  prefixIcon: const Icon(Icons.lock, color: AppColors.color2),
                  filled: true,
                  fillColor: AppColors.color12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.color2,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                    value!.length < 6 ? "Password must be at least 6 characters" : null,
              ),
              const SizedBox(height: 16.0),

              // Contact Field
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: "Contact",
                  labelStyle: const TextStyle(color: AppColors.color2),
                  prefixIcon: const Icon(Icons.phone, color: AppColors.color2),
                  filled: true,
                  fillColor: AppColors.color12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Contact number is required" : null,
              ),
              const SizedBox(height: 16.0),

              // Matric Number Field
              TextFormField(
                controller: _matricController,
                decoration: InputDecoration(
                  labelText: "Matric Number",
                  labelStyle: const TextStyle(color: AppColors.color2),
                  prefixIcon: const Icon(Icons.numbers, color: AppColors.color2),
                  filled: true,
                  fillColor: AppColors.color12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Matric number is required" : null,
              ),
              const SizedBox(height: 20.0),

              // User Type Selection (Informative Only)
              Text(
                "Sign up as:",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.color10.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: "Buyer",
                items: const [
                  DropdownMenuItem(value: "Buyer", child: Text("Buyer", style: TextStyle(color: AppColors.color10))),
                ],
                onChanged: null, // Disables the dropdown
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.color12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                dropdownColor: AppColors.color12,
              ),
              const SizedBox(height: 6.0),
              Text(
                "Note: First-time users will be registered as Buyer. You can apply as Seller later in your profile.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24.0),

              const SizedBox(height: 24.0),

              // Sign-Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color2, // Maroon button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: signupViewModel.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await signupViewModel.registerUser(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              contact: _contactController.text,
                              matric: _matricController.text,
                              context: context,
                            );

                            if (success) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Verify Your Email"),
                                  content: Text(
                                    "A verification email has been sent to ${_emailController.text}. Please check your inbox.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Registration Failed"),
                                  backgroundColor: AppColors.color8, // Error red
                                ),
                              );
                            }
                          }
                        },
                  child: signupViewModel.isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.base, // Cream loading indicator
                        )
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.base, // Cream text
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Login Option
              const SizedBox(height: 20.0),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/sign_in");
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: AppColors.color10.withOpacity(0.6),
                      ),
                      children: const [
                        TextSpan(
                          text: "Sign In",
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
    );
  }
}