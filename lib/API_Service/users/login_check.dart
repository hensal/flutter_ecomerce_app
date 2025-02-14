import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      return false;
    }

    // Check if the token is expired
    if (JwtDecoder.isExpired(token)) {
      return false;
    }

    return true;
  }
}
