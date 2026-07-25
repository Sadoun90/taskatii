import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  Widget _buildStatItem(String label, String count, Color color, BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: getSmallTextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: AppLocalStorage.userBox.listenable(),
      builder: (context, box, child) {
        String name =
            AppLocalStorage.getCachedData(AppLocalStorage.KName) ?? 'User';

        return ValueListenableBuilder(
          valueListenable: AppLocalStorage.taskBox.listenable(),
          builder: (context, Box<TaskModel> taskBox, child) {
            int completedTasks =
                taskBox.values.where((t) => t.isCompleted).length;
            int totalTasks = taskBox.length;

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $name 👋',
                        overflow: TextOverflow.ellipsis,
                        style: getTitleTextStyle(
                          context,
                          color: AppColors.primaryColor,
                          fontSize: 20,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Have a productive day!',
                        style: getBodyTextStyle(
                          context,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                // Clickable Task Tracker Badge
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor:
                          isDark ? Colors.grey.shade900 : Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        double pct =
                            totalTasks > 0 ? (completedTasks / totalTasks) : 0;
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const Gap(16),
                              Text(
                                '🔥 Daily Productivity Stats',
                                style: getTitleTextStyle(context, fontSize: 18),
                              ),
                              const Gap(20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('Total', '$totalTasks',
                                      AppColors.primaryColor, context),
                                  _buildStatItem('Completed', '$completedTasks',
                                      Colors.green, context),
                                  _buildStatItem(
                                      'Pending',
                                      '${totalTasks - completedTasks}',
                                      Colors.orange,
                                      context),
                                ],
                              ),
                              const Gap(20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: Colors.grey.shade300,
                                  color: AppColors.primaryColor,
                                  minHeight: 10,
                                ),
                              ),
                              const Gap(10),
                              Text(
                                '${(pct * 100).toInt()}% Tasks Completed',
                                style: getSmallTextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.accentColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: Colors.amberAccent,
                        ),
                        const Gap(6),
                        Text(
                          totalTasks > 0
                              ? '$completedTasks/$totalTasks Done'
                              : '🔥 Streak',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
}
