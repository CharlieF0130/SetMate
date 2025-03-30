class User {
  final String email;
  final String password;
  final String? username; // 可选字段，用于注册时

  User({
    required this.email,
    required this.password,
    this.username,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'email': email,
      'password': password,
    };

    if (username != null) {
      data['username'] = username!;
    }

    return data;
  }
}
