import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String contactNumber,
    required String matricNumber,
    required String userType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "contact_number": contactNumber,
        "matric_number": matricNumber,
        'user_type': userType,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data['email'];
    } else {
      return null;
    }
  }
}
