import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:setmate_app/models/profile.dart';
import 'package:setmate_app/services/profile_service.dart';
import 'package:setmate_app/services/token_service.dart';
import 'package:setmate_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  bool _loading = true;
  String? _username;

  final Map<String, bool> _editMode = {
    'age': false,
    'height': false,
    'currentWeight': false,
    'goalWeight': false,
    'bodyFatPercentage': false,
  };

  final Map<String, TextEditingController> _controllers = {
    'age': TextEditingController(),
    'height': TextEditingController(),
    'currentWeight': TextEditingController(),
    'goalWeight': TextEditingController(),
    'bodyFatPercentage': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.fetchProfile();

    if (profile == null) {
      print("📌 No profile found. Creating new one...");

      final created = await ProfileService.updateProfile(UserProfile(
        age: null,
        height: null,
        currentWeight: null,
        goalWeight: null,
        bodyFatPercentage: null,
      ));

      if (created) {
        print("✅ New profile created. Refetching...");
        final newProfile = await ProfileService.fetchProfile();
        if (newProfile != null) {
          _controllers['age']!.text = newProfile.age?.toString() ?? '';
          _controllers['height']!.text = newProfile.height?.toString() ?? '';
          _controllers['currentWeight']!.text =
              newProfile.currentWeight?.toString() ?? '';
          _controllers['goalWeight']!.text =
              newProfile.goalWeight?.toString() ?? '';
          _controllers['bodyFatPercentage']!.text =
              newProfile.bodyFatPercentage?.toString() ?? '';
          setState(() {
            _profile = newProfile;
            _loading = false;
          });
          return;
        }
      }

      print("❌ Failed to create initial profile");
      setState(() {
        _loading = false;
      });
      return;
    }

    // 正常 profile 存在的逻辑
    _controllers['age']!.text = profile.age?.toString() ?? '';
    _controllers['height']!.text = profile.height?.toString() ?? '';
    _controllers['currentWeight']!.text =
        profile.currentWeight?.toString() ?? '';
    _controllers['goalWeight']!.text = profile.goalWeight?.toString() ?? '';
    _controllers['bodyFatPercentage']!.text =
        profile.bodyFatPercentage?.toString() ?? '';
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _saveField(String field) async {
    if (_profile == null) return;
    setState(() {
      _editMode[field] = false;
    });
    switch (field) {
      case 'age':
        _profile!.age = int.tryParse(_controllers[field]!.text);
        break;
      case 'height':
        _profile!.height = double.tryParse(_controllers[field]!.text);
        break;
      case 'currentWeight':
        _profile!.currentWeight = double.tryParse(_controllers[field]!.text);
        break;
      case 'goalWeight':
        _profile!.goalWeight = double.tryParse(_controllers[field]!.text);
        break;
      case 'bodyFatPercentage':
        _profile!.bodyFatPercentage =
            double.tryParse(_controllers[field]!.text);
        break;
    }
    await ProfileService.updateProfile(_profile!);
  }

  Widget _buildEditableCard(
      String label, String fieldKey, String unit, double screenWidth) {
    final isEditing = _editMode[fieldKey]!;
    final valueText = _controllers[fieldKey]!.text;

    double cardWidth = screenWidth * 0.42; // 响应式宽度
    double cardHeight = cardWidth * 0.85; // 比例高度

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFECECEC)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit,
                  size: 16, color: Colors.grey),
              onPressed: () {
                if (isEditing) {
                  _saveField(fieldKey);
                }
                setState(() {
                  _editMode[fieldKey] = !isEditing;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF2A6049),
                    fontSize: 14,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                isEditing
                    ? SizedBox(
                        height: 28,
                        width: 60,
                        child: TextField(
                          controller: _controllers[fieldKey],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 2),
                            border: UnderlineInputBorder(),
                          ),
                          onSubmitted: (_) => _saveField(fieldKey),
                        ),
                      )
                    : Text(
                        valueText,
                        style: const TextStyle(
                          color: Color(0xFF140C07),
                          fontSize: 20,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFFBFC0C0),
                    fontSize: 14,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: kButtonColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              _profile?.username ?? 'Username',
              textAlign: TextAlign.center,
              style: GoogleFonts.pacifico(
                color: const Color(0xFF140C07),
                fontSize: 24,
                fontWeight: FontWeight.w400,
                height: 1.56,
              ),
            ),

            const SizedBox(height: 24),
            // Wrap 外层加 Center
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  _buildEditableCard("Age", "age", "yrs", screenWidth),
                  _buildEditableCard("Height", "height", "cm", screenWidth),
                  _buildEditableCard(
                      "Weight", "currentWeight", "kg", screenWidth),
                  _buildEditableCard("Goal", "goalWeight", "kg", screenWidth),
                  _buildEditableCard(
                      "Body Fat", "bodyFatPercentage", "%", screenWidth),
                ],
              ),
            ),

            const SizedBox(height: 32),

// 登出按钮用 Center 包裹
            Center(
              child: GestureDetector(
                onTap: () async {
                  await TokenService.clearToken(); // 使用你封装的方法
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Container(
                  width: 342,
                  height: 48,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFD9534F), // 红色边框
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Logout',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD9534F), // 红色文字
                      fontSize: 16,
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
