import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:setmate_app/services/profile_service.dart';
import 'package:setmate_app/services/summary_service.dart';
import 'package:setmate_app/utils/constants.dart';
import 'package:setmate_app/utils/date_utils.dart';

class ExerciseSummaryPage extends StatefulWidget {
  const ExerciseSummaryPage({super.key});

  @override
  State<ExerciseSummaryPage> createState() => _ExerciseSummaryPageState();
}

class _ExerciseSummaryPageState extends State<ExerciseSummaryPage> {
  String selectedRange = 'Week';
  final List<String> ranges = ['Week', 'Month', 'Year'];
  DateTime currentStartDate = DateTime.now();

  List<double> chartValues = [];
  double avgMinutes = 0;
  double totalMinutes = 0;
  String chartUnit = '';

  String goalDailyTime = '';
  String currentWeight = '';
  String goalWeight = '';

  @override
  void initState() {
    super.initState();
    _fetchChartData();
    _fetchProfile();
  }

  void _fetchProfile() async {
    final profile = await ProfileService.fetchProfile();
    if (profile != null) {
      setState(() {
        goalDailyTime = profile.goalDailyTime?.toString() ?? ' UNKNOWN';
        goalWeight = '${profile.goalWeight?.toStringAsFixed(1) ?? 'UNKNOWN'}kg';
        currentWeight =
            '${profile.currentWeight?.toStringAsFixed(1) ?? 'UNKNOWN'}kg';
      });
    }
  }

  void _fetchChartData() async {
    // 对 Week 视图做“周一”对齐
    if (selectedRange == 'Week') {
      currentStartDate = _getStartOfWeek(currentStartDate);
    }

    final startStr = DateFormat('yyyy-MM-dd').format(currentStartDate);
    final summary = await SummaryService.fetchSummary(
        selectedRange.toLowerCase(), startStr);

    double divisor;
    switch (selectedRange) {
      case 'Week':
        divisor = 7;
        break;
      case 'Month':
        final daysInMonth = DateUtils.getDaysInMonth(
            currentStartDate.year, currentStartDate.month);
        divisor = daysInMonth.toDouble();
        break;
      case 'Year':
        final isLeap = DateTime(currentStartDate.year).isLeapYear;
        divisor = isLeap ? 366 : 365;
        break;
      default:
        divisor = 1;
    }

    setState(() {
      chartValues = List<double>.from(summary.values);
      totalMinutes = summary.totalMinutes.toDouble();
      avgMinutes = totalMinutes / divisor;
      chartUnit = summary.unit;
    });

    print('=== Summary Chart Debug ===');
    print('Range: $selectedRange');
    print('Start Date: $currentStartDate');
    print('Chart Unit: $chartUnit');
    print('Chart Values: $chartValues');
    print('Total Minutes: $totalMinutes');
    print('Average Minutes per day: ${avgMinutes.toStringAsFixed(3)}');
    print('===========================');
  }

  bool _isAtLatestPeriod() {
    final now = DateTime.now();

    switch (selectedRange) {
      case 'Week':
        final startOfNextWeek = currentStartDate.add(const Duration(days: 7));
        return startOfNextWeek.isAfter(now);
      case 'Month':
        final nextMonth =
            DateTime(currentStartDate.year, currentStartDate.month + 1);
        return nextMonth.isAfter(now);
      case 'Year':
        final nextYear = DateTime(currentStartDate.year + 1);
        return nextYear.isAfter(now);
      default:
        return true;
    }
  }

  void _navigatePeriod(bool forward) {
    final delta = forward ? 1 : -1;
    DateTime newStart;

    switch (selectedRange) {
      case 'Week':
        newStart = currentStartDate.add(Duration(days: 7 * delta));
        break;
      case 'Month':
        newStart =
            DateTime(currentStartDate.year, currentStartDate.month + delta);
        break;
      case 'Year':
        newStart = DateTime(currentStartDate.year + delta);
        break;
      default:
        return;
    }

    final now = DateTime.now();

    // 禁止跳转到未来时间
    if (newStart.isAfter(now)) return;

    setState(() {
      currentStartDate = newStart;
    });
    _fetchChartData();
  }

  DateTime _getStartOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  String _getFormattedRange() {
    switch (selectedRange) {
      case 'Week':
        final end = currentStartDate.add(const Duration(days: 6));
        return "${_formatDateWithYear(currentStartDate)} - ${_formatDateWithYear(end)}";
      case 'Month':
        return DateFormat('MMMM yyyy').format(currentStartDate);
      case 'Year':
        return currentStartDate.year.toString();
      default:
        return '';
    }
  }

  String _formatDateWithYear(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatDate(DateTime d) => DateFormat('MMM d').format(d);

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        barGroups: chartValues.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                width: 8,
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartValues.length)
                  return const SizedBox();
                switch (chartUnit) {
                  case 'day':
                    const days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ];
                    return Text(days[index],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10));
                  case 'week':
                    return Text('W${index + 1}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10));
                  case 'month':
                    const months = [
                      'J',
                      'F',
                      'M',
                      'A',
                      'M',
                      'J',
                      'J',
                      'A',
                      'S',
                      'O',
                      'N',
                      'D'
                    ];
                    return Text(months[index],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10));
                  default:
                    return const SizedBox();
                }
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.3),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.white),
            left: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDataCard(String label, String value) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: Color(0xFFBFC0C0),
                fontSize: 14,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w500,
                height: 1.43,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                color: Color(0xFF140C07),
                fontSize: 16,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w600,
                height: 1.5,
              )),
        ],
      ),
    );
  }

  void _showEditGoalDialog() {
    final timeController = TextEditingController(text: goalDailyTime);
    final weightController =
        TextEditingController(text: goalWeight.replaceAll('kg', ''));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5F5F5), // kBackgroundColor
              title: const Text(
                "Edit Goal",
                style: TextStyle(color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Daily Goal Time (min)'),
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Goal Weight (kg)'),
                  ),
                ],
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
                      borderRadius: BorderRadius.circular(20),
                      side:
                          const BorderSide(width: 1, color: Color(0xFFEC744A)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () async {
                    setState(() {
                      goalDailyTime = timeController.text;
                      goalWeight = '${weightController.text}kg';
                    });

                    final profile = await ProfileService.fetchProfile();
                    if (profile != null) {
                      profile.goalDailyTime = int.tryParse(timeController.text);
                      profile.goalWeight =
                          double.tryParse(weightController.text);
                      await ProfileService.updateProfile(profile);
                    }

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final timeDisplay = '${avgMinutes.toStringAsFixed(3)}/${goalDailyTime} min';

    return Scaffold(
      backgroundColor: kButtonColor,
      appBar: AppBar(
        backgroundColor: kButtonColor,
        title: Row(
          children: [
            const Expanded(
              child: Text('Exercise Summary',
                  style: TextStyle(color: Colors.white)),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRange,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                iconEnabledColor: Colors.white,
                selectedItemBuilder: (BuildContext context) {
                  return ranges.map((String item) {
                    return Row(
                      children: [
                        Text(item, style: const TextStyle(color: Colors.white)),
                      ],
                    );
                  }).toList();
                },
                items: ranges.map((range) {
                  return DropdownMenuItem<String>(
                    value: range,
                    child: Text(range),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRange = value;
                      if (value == 'Week') {
                        currentStartDate = _getStartOfWeek(DateTime.now());
                      } else {
                        currentStartDate = DateTime.now();
                      }
                    });
                    _fetchChartData();
                  }
                },
              ),
            )
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => _navigatePeriod(false),
                ),
                Text(
                  _getFormattedRange(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios,
                      color: _isAtLatestPeriod() ? Colors.grey : Colors.white),
                  onPressed:
                      _isAtLatestPeriod() ? null : () => _navigatePeriod(true),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 4),
            child: Text(
              'Average Daily Time: ${avgMinutes.toStringAsFixed(1)} min',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            child: _buildChart(),
          ),
          const Spacer(),
          Container(
            width: screenWidth,
            height: 310,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVerticalDataCard('Goal Daily Time', timeDisplay),
                const SizedBox(height: 16),
                _buildVerticalDataCard('Weight', currentWeight),
                const SizedBox(height: 16),
                _buildVerticalDataCard('Goal Weight', goalWeight),
                const Spacer(),
                GestureDetector(
                  onTap: _showEditGoalDialog,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: kButtonColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Edit Goal',
                      style: TextStyle(
                        color: kButtonColor,
                        fontSize: 16,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
