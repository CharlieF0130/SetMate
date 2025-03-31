import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:setmate_app/models/calendar_summary.dart';
import 'package:setmate_app/models/daily_training_detail.dart';
import 'package:setmate_app/utils/constants.dart';
import 'package:setmate_app/services/token_service.dart';

class ApiService {
  static const String baseUrl = historyUrl;

  static Future<List<CalendarSummary>> fetchCalendarSummary(
      String month) async {
    final headers = await TokenService.getAuthHeader();
    final response = await http.get(
      Uri.parse('$baseUrl/calendar?month=$month'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final list = json.decode(response.body) as List;
      return list.map((e) => CalendarSummary.fromJson(e)).toList();
    } else {
      throw Exception('获取训练日历失败: ${response.statusCode}');
    }
  }

  static Future<DailyTrainingDetail> fetchTrainingDetail(DateTime date) async {
    final headers = await TokenService.getAuthHeader();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(
      Uri.parse('$baseUrl/details?date=$dateStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return DailyTrainingDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('获取训练详情失败: ${response.statusCode}');
    }
  }

  static Future<List<DailyTrainingDetail>> fetchAllTrainingsOnDate(
      DateTime date) async {
    final headers = await TokenService.getAuthHeader();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(
      Uri.parse('$baseUrl/details/multiple?date=$dateStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final list = json.decode(response.body) as List;
      return list.map((e) => DailyTrainingDetail.fromJson(e)).toList();
    } else {
      throw Exception('获取该日多个训练失败: ${response.statusCode}');
    }
  }

  static Future<bool> updateExercise(Exercise exercise) async {
  final headers = await TokenService.getAuthHeader();
  headers['Content-Type'] = 'application/json';

  final body = {
    "exerciseName": exercise.exerciseName,
    "sets": exercise.sets,
    "reps": exercise.reps,
    "weight": exercise.weight,
    "restTime": exercise.restTime,
    "type": exercise.type,
  };

  print('📤 PATCH TO BACKEND: ${json.encode(body)}');

  final response = await http.put(
    Uri.parse('$exerciseUrl/${exercise.exerciseId}'),
    headers: headers,
    body: json.encode(body),
  );

  print('📩 RESPONSE: ${response.statusCode} - ${response.body}');
  return response.statusCode == 200;
}

static Future<bool> deleteExercise(int exerciseId) async {
  final headers = await TokenService.getAuthHeader();

  final response = await http.delete(
    Uri.parse('$exerciseUrl/$exerciseId'),
    headers: headers,
  );

  print('🗑️ DELETE RESPONSE: ${response.statusCode} - ${response.body}');
  return response.statusCode == 200;
}


}
