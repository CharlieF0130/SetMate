import 'package:flutter/material.dart';
import 'package:setmate_app/models/training_exercise.dart';
import 'package:setmate_app/services/token_service.dart';
import 'package:setmate_app/services/training_service.dart';
import 'package:setmate_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

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
  final TextEditingController titleController = TextEditingController();
  bool isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    fetchUsername();
    loadDraft();
  }

  void saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('training_draft_title', titleController.text);
    await prefs.setString('training_draft_note', noteController.text);
    await prefs.setString('training_draft_exercises', jsonEncode(exercises));
  }

  void loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTitle = prefs.getString('training_draft_title');
    final savedNote = prefs.getString('training_draft_note');
    final savedExercises = prefs.getString('training_draft_exercises');

    if (savedTitle != null || savedNote != null || savedExercises != null) {
      setState(() {
        titleController.text = savedTitle ?? '';
        noteController.text = savedNote ?? '';
        if (savedExercises != null) {
          exercises =
              List<Map<String, dynamic>>.from(jsonDecode(savedExercises));
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // 停止计时器，避免内存泄漏
    saveDraft(); // 👉 保存训练草稿
    super.dispose();
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
              backgroundColor: kBackgroundColor,
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
                      fontSize: 14,
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

  void showEditExerciseDialog(int index) {
    final original = exercises[index];

    final TextEditingController nameController =
        TextEditingController(text: original['exerciseName']);
    final TextEditingController setsController =
        TextEditingController(text: original['sets'].toString());
    final TextEditingController repsController =
        TextEditingController(text: original['reps'].toString());
    final TextEditingController weightController =
        TextEditingController(text: original['weight'].toString());
    final TextEditingController restController =
        TextEditingController(text: original['restTime'].toString());
    final TextEditingController customTypeController =
        TextEditingController(text: original['type'] ?? '');

    final List<String> presetTypes = [
      'Chest',
      'Back',
      'Legs',
      'Glutes',
      'Abs',
      'Cardio',
      'Custom'
    ];
    String? selectedType =
        presetTypes.contains(original['type']) ? original['type'] : 'Custom';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: kBackgroundColor,
              title: const Text("Edit Exercise",
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
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFEC744A)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    final type = selectedType == 'Custom'
                        ? customTypeController.text
                        : selectedType;

                    final updatedExercise = {
                      'exerciseName': nameController.text,
                      'sets': int.tryParse(setsController.text) ?? 0,
                      'reps': int.tryParse(repsController.text) ?? 0,
                      'weight': double.tryParse(weightController.text) ?? 0.0,
                      'restTime': int.tryParse(restController.text) ?? 0,
                      'type': type,
                    };

                    setState(() {
                      exercises[index] = updatedExercise;
                    });

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Color(0xFFEC744A),
                      fontSize: 14,
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
      trainingStartTime = DateTime.now();
      trainingDuration = Duration.zero;
      showNoteField = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        trainingDuration = DateTime.now().difference(trainingStartTime!);
      });
    });
  }

  void finishTraining() async {
    _timer?.cancel();
    final endTime = DateTime.now();

    setState(() {
      isTraining = false;
      showNoteField = false;
    });

    final exerciseModels = exercises
        .map((e) => TrainingExercise(
              exerciseName: e['exerciseName'],
              sets: e['sets'],
              reps: e['reps'],
              weight: e['weight'],
              restTime: e['restTime'],
              type: e['type'],
            ))
        .toList();

    final success = await TrainingService.completeTrainingSession(
      startTime: trainingStartTime!,
      endTime: endTime,
      exercises: exerciseModels,
      note: noteController.text,
      trainingTitle: titleController.text,
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('training_draft_title');
      prefs.remove('training_draft_note');
      prefs.remove('training_draft_exercises');

      setState(() {
        exercises.clear();
        titleController.clear();
        noteController.clear();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20,
          ),
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
              Row(
                children: [
                  if (isTraining)
                    Text(
                      "⏱ Training Time: ${trainingDuration.inMinutes.toString().padLeft(2, '0')}:${(trainingDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (isTraining) const SizedBox(width: 8),
                  Expanded(
                    child: isEditingTitle
                        ? TextField(
                            controller: titleController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: "Training title",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'PingFang SC',
                              fontWeight: FontWeight.w500,
                            ),
                            onSubmitted: (_) {
                              setState(() {
                                isEditingTitle = false;
                              });
                            },
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                isEditingTitle = true;
                              });
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.edit,
                                    size: 18, color: Color(0xFFBFC0C0)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    titleController.text.isEmpty
                                        ? "Training title"
                                        : titleController.text,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFBFC0C0),
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
                ],
              ),

              const SizedBox(height: 10),

              // 动作展示区域
              if (exercises.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Please add exercises to start training',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFBFC0C0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true, // ✅ 关键：让 ListView 自己决定高度
                  physics:
                      const NeverScrollableScrollPhysics(), // ✅ 禁用它自己的滚动，交给外层的 ScrollView
                  padding: EdgeInsets.zero,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final e = exercises[index];
                    return GestureDetector(
                      onTap: () => showEditExerciseDialog(index),
                      child: Container(
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
                        child: Stack(
                          children: [
                            // 主体内容
                            Column(
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
                                if (e['type'] != null)
                                  Text("Type: ${e['type']}"),
                              ],
                            ),
                            // 删除按钮
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    size: 20, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    exercises.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showNoteField)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                              borderSide:
                                  const BorderSide(color: Color(0xFFECECEC)),
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: showAddExerciseDialog,
                      child: Container(
                        height: 48,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFFEC744A)),
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
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (isTraining)
                          finishTraining();
                        else if (exercises.isNotEmpty) startTraining();
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: (!isTraining && exercises.isEmpty)
                              ? const Color(0xFFBFC0C0)
                              : const Color(0xFF2A6049),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isTraining ? 'Finish Training' : 'Start Training',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'PingFang SC',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
