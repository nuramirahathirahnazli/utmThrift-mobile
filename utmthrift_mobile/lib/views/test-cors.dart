//nak test cors in flutter

// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CORSCheckScreen extends StatefulWidget {
  @override
  _CORSCheckScreenState createState() => _CORSCheckScreenState();
}

class _CORSCheckScreenState extends State<CORSCheckScreen> {
  String message = 'Checking CORS...';

  @override
  void initState() {
    super.initState();
    _testCORS();
  }

  _testCORS() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/api/test-cors'));

      if (response.statusCode == 200) {
        setState(() {
          message = json.decode(response.body)['message'];
        });
      } else {
        setState(() {
          message = 'Failed to fetch data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CORS Test')),
      body: Center(
        child: Text(message),
      ),
    );
  }
}
