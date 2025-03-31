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

  @override
  void initState() {
    super.initState();
    _loadCalendarData(_focusedDay);
  }

 void showEditExerciseDialog(int trainingIndex, int exerciseIndex) {
  final exercise = _dailyTrainings[trainingIndex].exercises[exerciseIndex];
  final TextEditingController nameController = TextEditingController(text: exercise.exerciseName);
  final TextEditingController setsController = TextEditingController(text: exercise.sets.toString());
  final TextEditingController repsController = TextEditingController(text: exercise.reps.toString());
  final TextEditingController weightController = TextEditingController(text: exercise.weight.toString());
  final TextEditingController typeController = TextEditingController(text: exercise.type ?? '');
  final TextEditingController restTimeController = TextEditingController(text: exercise.restTime?.toString() ?? '');

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Edit Exercise"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: setsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Sets")),
              TextField(controller: repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Reps")),
              TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Weight (kg)")),
              TextField(controller: typeController, decoration: const InputDecoration(labelText: "Type")),
              TextField(controller: restTimeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Rest Time (sec)")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedExercise = Exercise(
                exerciseId: exercise.exerciseId, // 保持原有的 exerciseId 不变
                exerciseName: nameController.text,
                sets: int.tryParse(setsController.text) ?? 0,
                reps: int.tryParse(repsController.text) ?? 0,
                weight: double.tryParse(weightController.text) ?? 0.0,
                type: typeController.text.isNotEmpty ? typeController.text : null,
                restTime: int.tryParse(restTimeController.text),
              );
              setState(() {
                // 更新本地数据
                _dailyTrainings[trainingIndex].exercises[exerciseIndex] = updatedExercise;
              });

              // 调用 API 更新后端
              final success = await ApiService.updateExercise(updatedExercise);
              if (success) {
                Navigator.pop(context); // 关闭对话框
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update exercise.')),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
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

  Future<void> _onDaySelected(DateTime selectedDay, DateTime _) async {
    try {
      final details = await ApiService.fetchAllTrainingsOnDate(selectedDay);
      setState(() {
        _dailyTrainings = details;
        _currentPage = 0;
      });

      if (_dailyTrainings.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No training records for this day.')),
          );
        }
        return;
      }

      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: kBackgroundColor,
          builder: (_) => StatefulBuilder(
            builder: (context, setModalState) => SizedBox(
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
                        setModalState(() {
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
                              Text(
                                '${detail.trainingTitle} (${detail.startTime} - ${detail.endTime})',
                                style: Theme.of(context).textTheme.titleLarge,
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
                                      margin: const EdgeInsets.only(bottom: 12),
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
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                    "${e.sets} sets × ${e.reps} reps"),
                                                Text("Weight: ${e.weight} kg"),
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
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  // TODO: 实现删除逻辑
                                                },
                                              )
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
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch training detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load training detail. Please try again.')),
      );
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
      ),
    );
  }
}
