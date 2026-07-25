import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class TaskProgressWidget extends StatelessWidget {
  final List<TaskModel> tasks;

  const TaskProgressWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    int total = tasks.length;
    int completed = tasks.where((t) => t.isCompleted).length;
    double progress = total > 0 ? completed / total : 0;
    int percentage = (progress * 100).toInt();

    String message;
    if (percentage == 100) {
      message = "All tasks completed! Amazing work 🎉";
    } else if (percentage >= 50) {
      message = "You're over halfway there! Keep it up 💪";
    } else if (percentage > 0) {
      message = "Good start! Keep going 🚀";
    } else {
      message = "Ready to tackle your day? 🎯";
    }

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.primaryColor.withValues(alpha: 0.3), Colors.indigo.shade900]
              : [AppColors.primaryColor, const Color(0xff6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Progress",
                style: getTitleTextStyle(
                  context,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$completed / $total Done ($percentage%)",
                  style: getSmallTextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const Gap(10),
          Text(
            message,
            style: getSmallTextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
