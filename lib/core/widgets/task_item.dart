import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskModel model;
  final VoidCallback? onTap;

  const TaskItemWidget({
    super.key,
    required this.model,
    this.onTap,
  });

  IconData _getCategoryIcon(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'personal':
        return Icons.person_outline;
      case 'study':
        return Icons.menu_book_outlined;
      case 'health':
        return Icons.fitness_center;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.task_alt;
    }
  }

  Color _getPriorityColor(int? priority) {
    switch (priority) {
      case 0:
        return AppColors.highPriority;
      case 1:
        return AppColors.mediumPriority;
      case 2:
        return AppColors.lowPriority;
      default:
        return Colors.white.withValues(alpha: 0.8);
    }
  }

  String _getPriorityText(int? priority) {
    switch (priority) {
      case 0:
        return "HIGH";
      case 1:
        return "MED";
      case 2:
        return "LOW";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    if (model.isCompleted) {
      cardColor = const Color(0xFF10B981); // Modern Emerald Green for completed tasks
    } else {
      int prio = model.priority ?? model.color;
      switch (prio) {
        case 0: // High
          cardColor = AppColors.highPriority;
          break;
        case 1: // Medium
          cardColor = AppColors.mediumPriority;
          break;
        case 2: // Low
          cardColor = AppColors.lowPriority;
          break;
        default:
          cardColor = AppColors.primaryColor;
      }
    }

    int subTasksTotal = model.subTasks?.length ?? 0;
    int subTasksDone = 0;
    if (subTasksTotal > 0 && model.subTasksCompleted != null) {
      subTasksDone = model.subTasksCompleted!.where((element) => element).length;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Priority Header Row
                  Row(
                    children: [
                      if (model.category != null && model.category!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(model.category),
                                size: 12,
                                color: Colors.white,
                              ),
                              const Gap(4),
                              Text(
                                model.category!,
                                style: getSmallTextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(8),
                      ],
                      if (model.priority != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(model.priority),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getPriorityText(model.priority),
                            style: getSmallTextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (model.category != null || model.priority != null)
                    const Gap(8),
                  Text(
                    model.title,
                    style: getTitleTextStyle(
                      context,
                      color: AppColors.whiteColor,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const Gap(6),
                      Text(
                        '${model.startTime} - ${model.endTime}',
                        style: getSmallTextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 12,
                        ),
                      ),
                      if (subTasksTotal > 0) ...[
                        const Gap(12),
                        const Icon(
                          Icons.checklist_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const Gap(4),
                        Text(
                          '$subTasksDone/$subTasksTotal',
                          style: getSmallTextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (model.discription.isNotEmpty) ...[
                    const Gap(6),
                    Text(
                      model.discription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: getBodyTextStyle(
                        context,
                        color: AppColors.whiteColor.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Gap(10),
            Container(
              height: 70,
              width: 1,
              color: AppColors.whiteColor.withValues(alpha: 0.5),
            ),
            const Gap(8),
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                model.isCompleted ? "COMPLETED" : "TODO",
                style: getTitleTextStyle(
                  context,
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
