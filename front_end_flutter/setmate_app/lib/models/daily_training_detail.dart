class DailyTrainingDetail {
  final String trainingTitle;
  final String note;
  final String startTime;
  final String endTime;
  final List<Exercise> exercises;

  DailyTrainingDetail({
    required this.trainingTitle,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.exercises,
  });

  factory DailyTrainingDetail.fromJson(Map<String, dynamic> json) {
    return DailyTrainingDetail(
      trainingTitle: json['trainingTitle'],
      note: json['note'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }
}

class Exercise {
  final int exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight;
  final int? restTime;
  final String? type;

  Exercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    this.restTime,
    this.type,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      sets: json['sets'],
      reps: json['reps'],
      weight: (json['weight'] as num).toDouble(),
      restTime: json['restTime'],
      type: json['type'],
    );
  }
}


