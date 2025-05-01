class ExerciseSummary {
  final String unit;
  final List<double> values;
  final double avgMinutes;
  final double totalMinutes;

  ExerciseSummary({
    required this.unit,
    required this.values,
    required this.avgMinutes,
    required this.totalMinutes,
  });

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) {
    return ExerciseSummary(
      unit: json['unit'],
      values: (json['values'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      avgMinutes: (json['avgMinutes'] as num).toDouble(),
      totalMinutes: (json['totalMinutes'] as num).toDouble(),
    );
  }
}
