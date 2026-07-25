import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics & Productivity',
          style: getTitleTextStyle(context, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: AppLocalStorage.taskBox.listenable(),
        builder: (context, Box<TaskModel> taskBox, child) {
          List<TaskModel> allTasks = taskBox.values.toList();
          int totalTasks = allTasks.length;
          int completedTasks = allTasks.where((t) => t.isCompleted).length;
          int pendingTasks = totalTasks - completedTasks;
          double completionRate =
              totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;
          int percentage = (completionRate * 100).toInt();

          // Priority counts
          int highCount = allTasks.where((t) => t.priority == 0).length;
          int medCount = allTasks.where((t) => t.priority == 1).length;
          int lowCount = allTasks.where((t) => t.priority == 2).length;

          // Category distribution
          Map<String, int> categoryCounts = {};
          for (var t in allTasks) {
            String cat = t.category ?? 'General';
            categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Productivity Rate Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        const Color(0xFF6C63FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Overall Completion Rate',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                '$percentage%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.insights_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completionRate,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // Stat Cards Grid (Total, Completed, Pending)
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      'Total Tasks',
                      '$totalTasks',
                      Icons.task,
                      AppColors.primaryColor,
                      isDark,
                    ),
                    const Gap(10),
                    _buildStatCard(
                      context,
                      'Completed',
                      '$completedTasks',
                      Icons.check_circle,
                      Colors.green,
                      isDark,
                    ),
                    const Gap(10),
                    _buildStatCard(
                      context,
                      'Pending',
                      '$pendingTasks',
                      Icons.pending_actions,
                      AppColors.orangeColor,
                      isDark,
                    ),
                  ],
                ),
                const Gap(24),

                // Priority Distribution Section
                Text(
                  'Tasks by Priority',
                  style: getTitleTextStyle(context, fontSize: 16),
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDistributionBar(
                        context,
                        'High Priority',
                        highCount,
                        totalTasks,
                        AppColors.highPriority,
                      ),
                      const Gap(12),
                      _buildDistributionBar(
                        context,
                        'Medium Priority',
                        medCount,
                        totalTasks,
                        AppColors.mediumPriority,
                      ),
                      const Gap(12),
                      _buildDistributionBar(
                        context,
                        'Low Priority',
                        lowCount,
                        totalTasks,
                        AppColors.lowPriority,
                      ),
                    ],
                  ),
                ),
                const Gap(24),

                // Category Breakdown Section
                Text(
                  'Category Breakdown',
                  style: getTitleTextStyle(context, fontSize: 16),
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                  ),
                  child: categoryCounts.isEmpty
                      ? const Center(
                          child: Text('No categories data available'),
                        )
                      : Column(
                          children: categoryCounts.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildDistributionBar(
                                context,
                                entry.key,
                                entry.value,
                                totalTasks,
                                AppColors.primaryColor,
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String count,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? color.withValues(alpha: 0.4) : color.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const Gap(8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Gap(4),
            Text(
              label,
              style: getSmallTextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    double fraction = total > 0 ? count / total : 0;
    int percentage = (fraction * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: getBodyTextStyle(context, fontSize: 13),
            ),
            Text(
              '$count ($percentage%)',
              style: getSmallTextStyle(fontSize: 12),
            ),
          ],
        ),
        const Gap(6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
