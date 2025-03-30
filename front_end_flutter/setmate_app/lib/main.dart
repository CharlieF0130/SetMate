import 'package:flutter/material.dart';
import 'package:setmate_app/pages/create_account_page.dart';
import 'package:setmate_app/pages/login_page.dart';
import 'package:setmate_app/pages/main_page.dart';
import 'package:setmate_app/pages/training_page.dart';
import 'package:setmate_app/pages/history_page.dart';
import 'package:setmate_app/pages/profile_page.dart';

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const CreateAccountPage(),
        '/main': (context) => const MainPage(),
        '/training': (context) => TrainingPage(),
        '/history': (context) => HistoryPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
