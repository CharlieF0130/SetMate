import 'package:flutter/material.dart';
import 'package:setmate_app/pages/exercise_summary_page.dart';
import 'training_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    TrainingPage(),
    HistoryPage(),
    ExerciseSummaryPage(),
    ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<String> titles = ['Workout', 'History', 'Summary', 'Me'];
  final List<IconData> icons = [
    Icons.fitness_center,
    Icons.history,
    Icons.bar_chart,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final navBarHeight = screenHeight * 0.08; // 比如导航栏占屏幕高的 9%

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        height: navBarHeight,
        margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.015),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(navBarHeight * 0.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1E000000),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(pages.length, (index) {
            final bool isSelected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTabTapped(index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  height: navBarHeight * 0.7,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2A6049)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[index],
                          size: navBarHeight * 0.35,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        const SizedBox(height: 2), // 减少间距
                        Text(
                          titles[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: navBarHeight * 0.18,
                            fontFamily: 'PingFang SC',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
