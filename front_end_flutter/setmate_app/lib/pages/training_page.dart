import 'package:flutter/material.dart';
import 'package:setmate_app/models/training_exercise.dart';
import 'package:setmate_app/services/token_service.dart';
import 'package:setmate_app/services/training_service.dart';
import 'package:setmate_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  String username = "User";
  List<Map<String, dynamic>> exercises = [];
  bool isTraining = false;
  DateTime? trainingStartTime;
  Duration trainingDuration = Duration.zero;
  Timer? _timer;
  final TextEditingController noteController = TextEditingController();
  bool showNoteField = false;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final headers = await TokenService.getAuthHeader();
    print("✅ Get headers: $headers");

    final response = await http.get(
      Uri.parse(usernameUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        username = data['username'];
      });
    }
  }

  void showAddExerciseDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController setsController = TextEditingController();
    final TextEditingController repsController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController restController = TextEditingController();
    final TextEditingController customTypeController = TextEditingController();

    final List<String> presetTypes = [
      'Chest',
      'Back',
      'Legs',
      'Glutes',
      'Abs',
      'Cardio',
      'Custom'
    ];
    String? selectedType;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor:kBackgroundColor,
              title: const Text("Add Exercise",
                  style: TextStyle(color: Colors.black)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: "Exercise Name")),
                    TextField(
                        controller: setsController,
                        decoration: const InputDecoration(labelText: "Sets"),
                        keyboardType: TextInputType.number),
                    TextField(
                        controller: repsController,
                        decoration: const InputDecoration(labelText: "Reps"),
                        keyboardType: TextInputType.number),
                    TextField(
                        controller: weightController,
                        decoration:
                            const InputDecoration(labelText: "Weight (kg)"),
                        keyboardType: TextInputType.number),
                    TextField(
                        controller: restController,
                        decoration:
                            const InputDecoration(labelText: "Rest Time (sec)"),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: "Exercise Type"),
                      value: selectedType,
                      items: presetTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedType = value;
                        });
                      },
                    ),
                    if (selectedType == 'Custom')
                      TextField(
                        controller: customTypeController,
                        decoration:
                            const InputDecoration(labelText: "Custom Type"),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFEC744A),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    final type = selectedType == 'Custom'
                        ? customTypeController.text
                        : selectedType;

                    final newExercise = {
                      'exerciseName': nameController.text,
                      'sets': int.tryParse(setsController.text) ?? 0,
                      'reps': int.tryParse(repsController.text) ?? 0,
                      'weight': double.tryParse(weightController.text) ?? 0.0,
                      'restTime': int.tryParse(restController.text) ?? 0,
                      'type': type,
                    };

                    Navigator.pop(context);

                    setState(() {
                      exercises.add(newExercise);
                    });
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(
                      color: Color(0xFFEC744A),
                      fontSize: 14, // 👉 比“Add Exercise”略小
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void startTraining() {
    setState(() {
      isTraining = true;
      trainingStartTime = DateTime.now(); // 记录训练开始时间
      trainingDuration = Duration.zero;
      showNoteField = true; // 👈 开始训练后显示 Note 输入框
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        trainingDuration = DateTime.now().difference(trainingStartTime!);
      });
    });
  }

  void finishTraining() async {
    _timer?.cancel();
    final endTime = DateTime.now(); // 记录训练结束时间

    setState(() {
      isTraining = false;
      showNoteField = false;
    });

    // 构建训练动作列表
    final exerciseModels = exercises
        .map((e) => TrainingExercise(
              exerciseName: e['exerciseName'],
              sets: e['sets'],
              reps: e['reps'],
              weight: e['weight'],
              restTime: e['restTime'],
              type: e['type'], // ✅ 添加这一行
            ))
        .toList();

    // 调用合并接口
    final success = await TrainingService.completeTrainingSession(
      startTime: trainingStartTime!,
      endTime: endTime,
      exercises: exerciseModels,
      note: noteController.text, // 👈 这里传入 note
    );

    if (success) {
      setState(() {
        exercises.clear();
      });
      print("✅ Training session & exercises uploaded");
    } else {
      print("❌ Failed to upload training");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boxWidth = screenWidth * 0.9;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello,',
              style: TextStyle(
                color: Color(0xFFBFC0C0),
                fontSize: 16,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              username,
              style: const TextStyle(
                color: Color(0xFF140C07),
                fontSize: 24,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w600,
                height: 1.67,
              ),
            ),
            const SizedBox(height: 12),
            if (isTraining)
              Text(
                "⏱ Training Time: ${trainingDuration.inMinutes.toString().padLeft(2, '0')}:${(trainingDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

            const SizedBox(height: 16),

            // 动作展示区域
            Expanded(
              child: exercises.isEmpty
                  ? const Center(
                      child: Text(
                        'Please add exercises to start training',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFBFC0C0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final e = exercises[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFECECEC),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${e['exerciseName']}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("${e['sets']} sets × ${e['reps']} reps"),
                              Text("Weight: ${e['weight']} kg"),
                              Text("Rest: ${e['restTime']} sec"),
                              if (e['type'] != null) Text("Type: ${e['type']}"),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (showNoteField)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Note',
                    hintText: 'Enter training note...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFECECEC)),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // 添加动作按钮
            GestureDetector(
              onTap: showAddExerciseDialog,
              child: Container(
                width: boxWidth,
                height: 48,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFEC744A),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Add Exercise',
                  style: TextStyle(
                    color: Color(0xFFEC744A),
                    fontSize: 16,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 开始或结束训练按钮
            GestureDetector(
              onTap: () {
                if (isTraining) {
                  finishTraining();
                } else {
                  if (exercises.isNotEmpty) {
                    startTraining();
                  }
                }
              },
              child: SizedBox(
                width: boxWidth,
                height: 48,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: boxWidth,
                        height: 48,
                        decoration: ShapeDecoration(
                          color: (!isTraining && exercises.isEmpty)
                              ? const Color(0xFFBFC0C0)
                              : const Color(0xFF2A6049),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 12,
                      child: Center(
                        child: Text(
                          isTraining ? 'Finish Training' : 'Start Training',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'PingFang SC',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
