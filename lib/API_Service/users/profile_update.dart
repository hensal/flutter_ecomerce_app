import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String apiUrl = "http://localhost:3006/api/update-profile";

  Future<String> updateProfile({
    required String name,
    required String email,
    required String image,
  }) async {
    try {
      // Retrieve the authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the headers
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "image": image,
        }),
      );

      if (response.statusCode == 200) {
        return "Profile updated successfully";
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody["message"] ?? "Failed to update profile";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
