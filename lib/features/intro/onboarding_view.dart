import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/features/auth/login_view.dart';
import 'package:taskatii/features/main_layout/main_layout.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Organize Your Tasks 🎯',
      'subtitle':
          'Categorize your daily tasks, set priorities, and keep your schedule clean & clear.',
      'type': 'tasks',
    },
    {
      'title': 'Smart Reminders & Alarms 🔔',
      'subtitle':
          'Never miss a deadline with scheduled local notification alarms that work 100% offline.',
      'type': 'alarms',
    },
    {
      'title': 'Track Your Productivity 📈',
      'subtitle':
          'Monitor your progress with live completion metrics and stay motivated every day.',
      'type': 'progress',
    },
  ];

  void _onFinish() {
    AppLocalStorage.casheData(AppLocalStorage.KIsUpload, true);
    bool isLoggedIn =
        AppLocalStorage.getCachedData(AppLocalStorage.KName) != null;
    if (isLoggedIn) {
      PushWithReplacement(context, const MainLayout());
    } else {
      PushWithReplacement(context, const LoginView());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Header: Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _onFinish,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // PageView Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Creative Visual Graphic Container
                        _buildIllustrationCard(item['type'], isDark),
                        const Gap(36),
                        Text(
                          item['title'],
                          textAlign: TextAlign.center,
                          style: getTitleTextStyle(
                            context,
                            color: AppColors.primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            item['subtitle'],
                            textAlign: TextAlign.center,
                            style: getBodyTextStyle(
                              context,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Footer: Custom Smooth Indicators & Next Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentIndex == index ? 28 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.primaryColor
                              : (isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 14),
                      elevation: 4,
                      shadowColor: AppColors.primaryColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (_currentIndex == _pages.length - 1) {
                        _onFinish();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentIndex == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const Gap(6),
                        Icon(
                          _currentIndex == _pages.length - 1
                              ? Icons.rocket_launch
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }

  // Creative Vector-Style Illustration Cards
  Widget _buildIllustrationCard(String type, bool isDark) {
    Color cardBg = isDark ? const Color(0xff1E1E2C) : Colors.indigo.shade50;

    if (type == 'tasks') {
      return Container(
        height: 240,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSampleTaskCard(
              title: "Design App Wireframes",
              category: "Work 💼",
              priority: "High 🔴",
              isDone: true,
              color: AppColors.primaryColor,
              isDark: isDark,
            ),
            const Gap(12),
            _buildSampleTaskCard(
              title: "Evening Gym Workout",
              category: "Health 🏋️",
              priority: "Medium 🟡",
              isDone: false,
              color: AppColors.orangeColor,
              isDark: isDark,
            ),
          ],
        ),
      );
    } else if (type == 'alarms') {
      return Container(
        height: 240,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.orangeColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.orangeColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orangeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                size: 48,
                color: AppColors.orangeColor,
              ),
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.alarm, color: Colors.orange, size: 20),
                  const Gap(10),
                  const Text(
                    "09:00 AM • Daily Standup",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Progress Slide
      return Container(
        height: 240,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.greenColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: CircularProgressIndicator(
                    value: 0.8,
                    strokeWidth: 8,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade300,
                    color: AppColors.greenColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "80%",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenColor,
                      ),
                    ),
                    const Text(
                      "Done",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.greenColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.greenColor, size: 18),
                  const Gap(6),
                  Text(
                    "4 of 5 Tasks Completed Today! 🎉",
                    style: TextStyle(
                      color: AppColors.greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildSampleTaskCard({
    required String title,
    required String category,
    required String priority,
    required bool isDone,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? Colors.green : Colors.grey,
            size: 20,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : null,
                  ),
                ),
                const Gap(2),
                Row(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const Gap(8),
                    Text(
                      priority,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
