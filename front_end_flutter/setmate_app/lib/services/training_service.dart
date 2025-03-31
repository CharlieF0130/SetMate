import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_exercise.dart';
import '../utils/constants.dart';

class TrainingService {
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken') ?? '';
  }

  /// 提交完整训练数据（training session + exercises）
  static Future<bool> completeTrainingSession({
  required DateTime startTime,
  required DateTime endTime,
  required List<TrainingExercise> exercises,
  required String note,
}) async {
  final token = await _getToken();

  final url = Uri.parse(completeUrl);

  final sessionPayload = {
    'date': startTime.toIso8601String().substring(0, 10),
    'startTime': startTime.toIso8601String().substring(11, 19),
    'endTime': endTime.toIso8601String().substring(11, 19),
    'note': note,
    'trainingType': 'General',
    'isCustomType': true,
  };

  final payload = {
    'session': sessionPayload,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    print("✅ Training complete uploaded successfully");
    return true;
  } else {
    print("❌ Failed to upload training complete: ${response.body}");
    return false;
  }
}

}
