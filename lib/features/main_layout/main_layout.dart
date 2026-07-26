import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/features/analytics/analytics_view.dart';
import 'package:taskatii/features/calendar/calendar_view.dart';
import 'package:taskatii/features/focus/focus_view.dart';
import 'package:taskatii/features/home/page/home_view.dart';
import 'package:taskatii/features/profile/profile_view.dart';

import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/features/home/widgets/task_details_sheet.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  final TaskModel? targetTask;

  const MainLayout({
    super.key,
    this.initialIndex = 0,
    this.targetTask,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int currentIndex;
  DateTime? lastPressedAt;

  final List<Widget> pages = const [
    HomeView(),
    CalendarView(),
    FocusView(),
    AnalyticsView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    if (widget.targetTask != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TaskDetailsSheet(task: widget.targetTask!),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If on another tab, return to Home tab first
        if (currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
          return;
        }

        final now = DateTime.now();
        if (lastPressedAt == null ||
            now.difference(lastPressedAt!) > const Duration(seconds: 2)) {
          lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 2),
              content: Text('Press back again to exit Taskatii 👋'),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            FocusScope.of(context).unfocus();
            setState(() {
              currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor:
              isDark ? Colors.grey.shade600 : Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Focus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
