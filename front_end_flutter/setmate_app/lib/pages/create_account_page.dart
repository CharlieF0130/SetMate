// create_account_page.dart
import 'package:flutter/material.dart';
import 'package:setmate_app/models/user.dart';
import 'package:setmate_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _register() async {
    final user = User(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    final result = await AuthService().register(user);

    if (result.success) {
      setState(() {
        _successMessage = "Account created successfully! Please back to login.";
        _errorMessage = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      // ✅ 返回到登录页面
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context); // 回到 LoginPage
      });
    } else {
      setState(() {
        _errorMessage = result.message ?? 'Registration failed';
        _successMessage = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    }
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth * 0.85;
    final fieldHeight = 48.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFBFC0C0),
              fontSize: 14,
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: fieldWidth,
            height: fieldHeight,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFECECEC)),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFFECECEC),
                    fontSize: 16,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.85;

    return GestureDetector(
      onTap: _register,
      child: Container(
        width: buttonWidth,
        height: 48,
        decoration: ShapeDecoration(
          color: const Color(0xFF2A6049),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Center(
          child: Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 返回上一页
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.04),
                  child: Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.07,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                _buildInputField(
                  label: 'Username',
                  hintText: 'Enter Username',
                  controller: _usernameController,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildInputField(
                  label: 'Email',
                  hintText: 'Enter Email',
                  controller: _emailController,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildInputField(
                  label: 'Password',
                  hintText: 'Enter Password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildRegisterButton(),
                SizedBox(height: screenHeight * 0.025),
                if (_errorMessage.isNotEmpty)
                  Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: screenWidth * 0.035,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (_successMessage.isNotEmpty)
                  Center(
                    child: Text(
                      _successMessage,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: screenWidth * 0.035,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
