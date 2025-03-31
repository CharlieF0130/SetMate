import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:setmate_app/models/profile.dart';
import 'package:setmate_app/services/token_service.dart';
import 'package:setmate_app/utils/constants.dart';

class ProfileService {
  static const String baseUrl = profileUrl;

  /// Get user profile via JWT
  static Future<UserProfile?> fetchProfile() async {
    final headers = await TokenService.getAuthHeader();
    if (headers.isEmpty) {
      print("❗No token found");
      return null;
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    print("🔵 Status Code: ${response.statusCode}");
    print("🔵 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      print("❌ Failed to load profile: ${response.statusCode}");
      return null;
    }
  }

  /// Update user profile via PUT with JWT
  static Future<bool> updateProfile(UserProfile profile) async {
    final headers = await TokenService.getAuthHeader();
    if (headers.isEmpty) return false;

    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode != 200) {
      print("❌ Failed to update profile: ${response.statusCode} ${response.body}");
    }

    return response.statusCode == 200;
  }
}
