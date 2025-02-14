import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>?> fetchUserProfile() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  if (token == null) {
    print('User not authenticated');
    return null;
  }

  final url = Uri.parse('http://localhost:3006/user/profile');
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch user profile: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
}



