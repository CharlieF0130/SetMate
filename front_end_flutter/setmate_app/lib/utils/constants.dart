//constants.dart
//const String baseUrl = 'http://10.0.2.2:8089'; // Android Emulator 使用本地地址
import 'package:flutter/material.dart';

const String baseUrl = 'http://127.0.0.1:8089'; //ios
const String loginUrl = '$baseUrl/api/users/login';
const String registerUrl = '$baseUrl/api/users/register';
const String usernameUrl = '$baseUrl/api/users/username';
const String completeUrl = '$baseUrl/api/training/complete';
const String historyUrl = '$baseUrl/api/history';
const String profileUrl = '$baseUrl/api/user-profile';
const String exerciseUrl = '$baseUrl/api/exercises';


const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kButtonColor = Color(0xFF2A6049);
