class CalendarSummary {
  final DateTime date;
  final String trainingTitle;

  CalendarSummary({required this.date, required this.trainingTitle});

  factory CalendarSummary.fromJson(Map<String, dynamic> json) {
    return CalendarSummary(
      date: DateTime.parse(json['date']),
      trainingTitle: json['trainingTitle'],
    );
  }
}