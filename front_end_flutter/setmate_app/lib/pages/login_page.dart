import 'package:flutter/material.dart';
import 'package:setmate_app/models/user.dart';
import 'package:setmate_app/services/auth_service.dart';
import 'package:setmate_app/services/token_service.dart';
import 'package:setmate_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _login() async {
    final user = User(
      email: _emailController.text,
      password: _passwordController.text,
    );

    final AuthResult result = await AuthService().login(user);

    if (result.success) {
      final token = await TokenService.getToken() ?? '';

      print("✅ Login successfully，JWT Token: $token");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successfully')),
      );
      if (token != null && token.contains('.')) {
  Navigator.pushReplacementNamed(context, '/main');
}


    } else {
      setState(() {
        _errorMessage = result.message ?? 'Login failed';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double fieldWidth = screenWidth * 0.85;

    return Container(
      width: fieldWidth,
      height: 76,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFBFC0C0),
                fontSize: 14,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 28,
            child: Container(
              width: fieldWidth,
              height: 48,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFECECEC)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.85;

    return GestureDetector(
      onTap: _login,
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
            'Login',
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.9,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 插入 Logo 图片
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: screenWidth * 0.7,
                      fit: BoxFit.contain,
                    ),
                  ),
                  _buildInputField(
                    label: 'Email',
                    hintText: 'Enter Email',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'Password',
                    hintText: 'Enter Password',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Center(
                      child: Text(
                        _successMessage,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
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
      ),
    );
  }
}
