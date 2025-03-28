// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  OTPVerificationScreen({required this.email});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

Future<void> verifyOTP() async {
  setState(() => isLoading = true);

  final response = await http.post(
    Uri.parse("http://127.0.0.1:8000/api/verify-otp"),
    body: {
      'email': widget.email,
      'otp': otpController.text.trim(),
    },
  );

  setState(() => isLoading = false);

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    // Show success message with green background
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP verified successfully! Redirecting to Login...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Wait 2 seconds before navigating to Login screen
    await Future.delayed(const Duration(seconds: 2));

    // Redirect to Login Page
    Navigator.of(context).pushReplacementNamed("/sign_in");


  } else {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['error'] ?? "Invalid OTP"),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Enter the OTP sent to your email"),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
  onPressed: isLoading ? null : verifyOTP,
  style: ElevatedButton.styleFrom(
    backgroundColor: isLoading ? Colors.grey : Colors.orange, // Disable color change
  ),
  child: isLoading
      ? const CircularProgressIndicator(color: Colors.white)
      : const Text('Verify OTP'),
),

          ],
        ),
      ),
    );
  }
}
