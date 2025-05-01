import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:setmate_app/models/exercise_summary.dart';
import 'package:setmate_app/utils/constants.dart';
import 'package:setmate_app/services/token_service.dart';

class SummaryService {
  static Future<ExerciseSummary> fetchSummary(String range, String startDate) async {
    final headers = await TokenService.getAuthHeader();
    final response = await http.get(
      Uri.parse('$baseUrl/api/summary?range=$range&start=$startDate'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ExerciseSummary.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load exercise summary');
    }
  }
}
