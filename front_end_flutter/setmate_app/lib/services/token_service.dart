import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const _tokenKey = 'jwtToken';

  /// Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Remove token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Check if token is valid (basic check: has 2 dots)
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    return token != null && token.split('.').length == 3;
  }

  /// Get token with Bearer prefix
  static Future<Map<String, String>> getAuthHeader() async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) {
      return {};
    }
    return {'Authorization': 'Bearer $token'};
  }
}
