import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthResult {
  final bool success;
  final String? message;

  AuthResult(this.success, [this.message]);
}

class AuthService {
  Future<AuthResult> login(User user) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', token);

        return AuthResult(true);
      } else {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Unknown error';
        return AuthResult(false, message);
      }
    } catch (e) {
      return AuthResult(false, 'Network error or invalid response: $e');
    }
  }

  // ✅ 注册功能
  Future<AuthResult> register(User user) async {
  try {
    final response = await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final message = body['message'] ?? 'Registration successful';
      return AuthResult(true, message);
    } else {
      final message = body['message'] ?? 'Unknown registration error';
      return AuthResult(false, message);
    }
  } catch (e) {
    return AuthResult(false, 'Network error or invalid response: $e');
  }
}

}
