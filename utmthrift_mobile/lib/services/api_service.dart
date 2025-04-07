import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
   static const String baseUrl = 'http://127.0.0.1:8000/api'; //localhost
  //static const String baseUrl = 'http://10.211.98.11:8000/api'; //real device
  
  static Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String contact,
    required String matric,
    required String userType,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "contact": contact,
        "matric": matric,
        "user_type": userType,
      }),
    );

    return response.statusCode == 201;
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }


}
