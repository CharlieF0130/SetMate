class UserProfile {
  final String? username;
  int? age;
  double? height;
  double? currentWeight;
  double? goalWeight;
  double? bodyFatPercentage;
  int? goalDailyTime; // ✅ 新增字段

  UserProfile({
    this.username,
    this.age,
    this.height,
    this.currentWeight,
    this.goalWeight,
    this.bodyFatPercentage,
    this.goalDailyTime, // ✅ 加入构造函数
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      age: json['age'],
      height: (json['height'] as num?)?.toDouble(),
      currentWeight: (json['currentWeight'] as num?)?.toDouble(),
      goalWeight: (json['goalWeight'] as num?)?.toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
      goalDailyTime: json['goalDailyTime'], // ✅ 反序列化
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'height': height,
      'currentWeight': currentWeight,
      'goalWeight': goalWeight,
      'bodyFatPercentage': bodyFatPercentage,
      'goalDailyTime': goalDailyTime, // ✅ 序列化
    };
  }
}
