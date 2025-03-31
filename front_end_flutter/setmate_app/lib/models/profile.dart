class UserProfile {
  final String? username; // ✅ 改成可选参数
  int? age;
  double? height;
  double? currentWeight;
  double? goalWeight;
  double? bodyFatPercentage;

  UserProfile({
    this.username,
    this.age,
    this.height,
    this.currentWeight,
    this.goalWeight,
    this.bodyFatPercentage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      age: json['age'],
      height: (json['height'] as num?)?.toDouble(),
      currentWeight: (json['currentWeight'] as num?)?.toDouble(),
      goalWeight: (json['goalWeight'] as num?)?.toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'height': height,
      'currentWeight': currentWeight,
      'goalWeight': goalWeight,
      'bodyFatPercentage': bodyFatPercentage,
    };
  }
}
