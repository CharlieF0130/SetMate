import 'package:flutter/material.dart';
import 'package:setmate_app/pages/create_account_page.dart';
import 'package:setmate_app/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SetMate App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/login', // 初始路由
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const CreateAccountPage(), // 注册页
      },
    );
  }
}
