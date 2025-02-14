import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String _url = 'http://localhost:3006/login';

  // Login user with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  
    } else {
      return {'error': 'Invalid credentials, Pleae re-check email and password!!!'}; 
    }
  }
}
