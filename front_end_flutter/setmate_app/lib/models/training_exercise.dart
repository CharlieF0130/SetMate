class TrainingExercise {
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight;
  final int restTime;
  final String? type; // ✅ 新增字段

  TrainingExercise({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restTime,
    this.type, // ✅ 正确初始化
  });

  factory TrainingExercise.fromJson(Map<String, dynamic> json) {
    return TrainingExercise(
      exerciseName: json['exerciseName'],
      sets: json['sets'],
      reps: json['reps'],
      weight: (json['weight'] ?? 0).toDouble(),
      restTime: json['restTime'],
      type: json['type'], // ✅ 可为空
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restTime': restTime,
      'type': type, // ✅ 传给后端
    };
  }
}
