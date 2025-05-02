import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:setmate_app/services/history_service.dart';
import 'package:setmate_app/utils/constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:setmate_app/models/daily_training_detail.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _eventMap = {};
  List<DailyTrainingDetail> _dailyTrainings = [];
  int _currentPage = 0;
  StateSetter? _modalSetState;

  @override
  void initState() {
    super.initState();
    _loadCalendarData(_focusedDay);
  }

  void showEditExerciseDialog(int trainingIndex, int exerciseIndex) {
    final exercise = _dailyTrainings[trainingIndex].exercises[exerciseIndex];

    final nameController = TextEditingController(text: exercise.exerciseName);
    final setsController =
        TextEditingController(text: exercise.sets.toString());
    final repsController =
        TextEditingController(text: exercise.reps.toString());
    final weightController =
        TextEditingController(text: exercise.weight.toString());
    final restController =
        TextEditingController(text: exercise.restTime?.toString() ?? '');
    final customTypeController = TextEditingController();

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

    // 如果原始类型是 preset，就选中；否则视为 custom
    if (exercise.type != null && presetTypes.contains(exercise.type)) {
      selectedType = exercise.type;
    } else {
      selectedType = 'Custom';
      customTypeController.text = exercise.type ?? '';
    }

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
                      dropdownColor: Colors.white,
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
                  onPressed: () async {
                    final type = selectedType == 'Custom'
                        ? customTypeController.text
                        : selectedType;

                    final updatedExercise = Exercise(
                      exerciseId: exercise.exerciseId,
                      exerciseName: nameController.text,
                      sets: int.tryParse(setsController.text) ?? 0,
                      reps: int.tryParse(repsController.text) ?? 0,
                      weight: double.tryParse(weightController.text) ?? 0.0,
                      restTime: int.tryParse(restController.text),
                      type: type,
                    );

                    final success =
                        await ApiService.updateExercise(updatedExercise);

                    if (success) {
                      setState(() {
                        _dailyTrainings[trainingIndex]
                            .exercises[exerciseIndex] = updatedExercise;
                      });

                      _modalSetState?.call(() {});
                      if (context.mounted) Navigator.pop(context);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('✅ Exercise updated successfully!')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('❌ Failed to update exercise.')),
                        );
                      }
                    }
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

  Future<void> _loadCalendarData(DateTime day) async {
    try {
      String monthStr = DateFormat('yyyy-MM').format(day);
      final data = await ApiService.fetchCalendarSummary(monthStr);
      setState(() {
        _eventMap = {};
        for (var item in data) {
          final date =
              DateTime.utc(item.date.year, item.date.month, item.date.day);
          _eventMap.update(date, (list) => list..add(item.trainingTitle),
              ifAbsent: () => [item.trainingTitle]);
        }
      });
    } catch (e) {
      debugPrint('❌ Failed to load calendar data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to load training history. Please try again.')),
      );
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return _eventMap[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  String _getDuration(String start, String end) {
    try {
      final startTime = DateFormat("HH:mm").parse(start);
      final endTime = DateFormat("HH:mm").parse(end);
      final duration = endTime.difference(startTime);
      return "Duration: ${duration.inMinutes} min";
    } catch (e) {
      return "";
    }
  }

  void _confirmAndDeleteSession(int trainingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
            'Are you sure you want to delete this training session and all its exercises?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ApiService.deleteSession(trainingId);

    if (success) {
  if (context.mounted) {
    Navigator.pop(context); // 关闭 modal
    await _loadCalendarData(_focusedDay); // ✅ 加上这句，刷新蓝点
    _onDaySelected(_focusedDay, _focusedDay); // 重新加载详情
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Session deleted successfully')),
    );
  }
}
 else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to delete session')),
        );
      }
    }
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime _,
      {bool showBottomSheet = true}) async {
    try {
      final details = await ApiService.fetchAllTrainingsOnDate(selectedDay);
      print(json.encode(details.map((e) => e.toJson()).toList()));

      setState(() {
        _dailyTrainings = details;
        _currentPage = 0;
      });

      if (_dailyTrainings.isEmpty) {
        if (context.mounted && showBottomSheet) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No training records for this day.')),
          );
        }
        return;
      }

      if (context.mounted && showBottomSheet) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: kBackgroundColor,
          builder: (_) => StatefulBuilder(
            builder: (context, setState) {
              _modalSetState = setState; // 👈 保存 modal 层的 setState，用于之后局部刷新
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.70,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _dailyTrainings.length,
                          (index) => Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentPage
                                  ? Colors.blue
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        itemCount: _dailyTrainings.length,
                        onPageChanged: (index) {
                          _modalSetState?.call(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final detail = _dailyTrainings[index];
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${detail.trainingTitle} (${detail.startTime} - ${detail.endTime})',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_forever,
                                          color: Colors.red),
                                      tooltip: 'Delete Session',
                                      onPressed: () => _confirmAndDeleteSession(
                                          detail.trainingId),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 4.0),
                                  child: Text(
                                    _getDuration(
                                        detail.startTime, detail.endTime),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                if (detail.note.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0, bottom: 12.0),
                                    child: Text('Note: ${detail.note}',
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic)),
                                  ),
                                const Divider(),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: detail.exercises.length,
                                    itemBuilder: (context, i) {
                                      final e = detail.exercises[i];
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                              width: 1,
                                              color: Color(0xFFECECEC),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.exerciseName,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                      "${e.sets} sets × ${e.reps} reps"),
                                                  Text(
                                                      "Weight: ${e.weight} kg"),
                                                  if (e.restTime != null)
                                                    Text(
                                                        "Rest: ${e.restTime} sec"),
                                                  if (e.type != null)
                                                    Text("Type: ${e.type}"),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Colors.orange),
                                                  onPressed: () {
                                                    showEditExerciseDialog(
                                                        index, i);
                                                  },
                                                ),
                                                IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    onPressed: () async {
                                                      final confirm =
                                                          await showDialog<
                                                              bool>(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Delete Exercise'),
                                                            content: const Text(
                                                                'Are you sure you want to delete this exercise?'),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          false),
                                                                  child: const Text(
                                                                      'Cancel')),
                                                              TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          true),
                                                                  child: const Text(
                                                                      'Delete')),
                                                            ],
                                                          );
                                                        },
                                                      );

                                                      if (confirm != true)
                                                        return;

                                                      final exerciseId =
                                                          _dailyTrainings[index]
                                                              .exercises[i]
                                                              .exerciseId;
                                                      final success =
                                                          await ApiService
                                                              .deleteExercise(
                                                                  exerciseId);

                                                      if (success) {
                                                        setState(() {
                                                          _dailyTrainings[index]
                                                              .exercises
                                                              .removeAt(i);
                                                        });

                                                        _modalSetState
                                                            ?.call(() {});

                                                        if (context.mounted) {
                                                          Navigator.pop(
                                                              context); // 关闭 BottomSheet
                                                          _onDaySelected(
                                                              _focusedDay,
                                                              _focusedDay); // 重新拉数据并弹出
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    '✅ Exercise deleted successfully!')),
                                                          );
                                                        }
                                                      } else {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    '❌ Failed to delete exercise.')),
                                                          );
                                                        }
                                                      }
                                                    })
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch training detail: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Failed to load training detail. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2A6049),
          title: const Text(
            'Training History',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2022),
          lastDay: DateTime(2030),
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
          headerVisible: true,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          eventLoader: _getEventsForDay,
          selectedDayPredicate: (day) => false,
          onDaySelected: _onDaySelected,
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            _loadCalendarData(focusedDay);
          },
          calendarStyle: const CalendarStyle(
            markerDecoration:
                BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          ),
        ));
  }
}
