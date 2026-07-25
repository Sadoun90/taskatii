import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/services/notification_service.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/features/add_task/add_task.dart';

class TaskDetailsSheet extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsSheet({super.key, required this.task});

  @override
  State<TaskDetailsSheet> createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends State<TaskDetailsSheet> {
  late TaskModel currentTask;
  late List<bool> subTasksCompletedState;

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
    int len = currentTask.subTasks?.length ?? 0;
    if (currentTask.subTasksCompleted != null &&
        currentTask.subTasksCompleted!.length == len) {
      subTasksCompletedState = List<bool>.from(currentTask.subTasksCompleted!);
    } else {
      subTasksCompletedState = List.filled(len, false);
    }
  }

  void _toggleSubTask(int index, bool? val) {
    setState(() {
      subTasksCompletedState[index] = val ?? false;
      currentTask.subTasksCompleted = subTasksCompletedState;

      // Sync overall task completion state with subtasks
      if (subTasksCompletedState.isNotEmpty &&
          subTasksCompletedState.every((element) => element)) {
        currentTask.isCompleted = true;
      } else {
        currentTask.isCompleted = false;
      }
    });

    AppLocalStorage.casheTaskData(currentTask.id, currentTask);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Gap(15),

            // Header: Category and Priority
            Row(
              children: [
                if (currentTask.category != null) ...[
                  Chip(
                    avatar: const Icon(Icons.category, size: 14),
                    label: Text(currentTask.category!),
                    backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: AppColors.primaryColor),
                  ),
                  const Gap(8),
                ],
                if (currentTask.priority != null) ...[
                  Chip(
                    label: Text(
                      currentTask.priority == 0
                          ? "High Priority"
                          : currentTask.priority == 1
                              ? "Medium Priority"
                              : "Low Priority",
                    ),
                    backgroundColor: currentTask.priority == 0
                        ? AppColors.highPriority.withValues(alpha: 0.15)
                        : currentTask.priority == 1
                            ? AppColors.mediumPriority.withValues(alpha: 0.15)
                            : AppColors.lowPriority.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: currentTask.priority == 0
                          ? AppColors.highPriority
                          : currentTask.priority == 1
                              ? AppColors.mediumPriority
                              : AppColors.lowPriority,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTask(task: currentTask),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Gap(10),

            // Title
            Text(
              currentTask.title,
              style: getTitleTextStyle(
                context,
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const Gap(8),

            // Time & Date
            Row(
              children: [
                Icon(Icons.calendar_month,
                    size: 16, color: AppColors.primaryColor),
                const Gap(4),
                Text(
                  currentTask.date,
                  style: getSmallTextStyle(color: AppColors.primaryColor),
                ),
                const Gap(15),
                Icon(Icons.access_time, size: 16, color: AppColors.primaryColor),
                const Gap(4),
                Text(
                  "${currentTask.startTime} - ${currentTask.endTime}",
                  style: getSmallTextStyle(color: AppColors.primaryColor),
                ),
              ],
            ),
            const Gap(15),

            // Description
            if (currentTask.discription.isNotEmpty) ...[
              Text(
                "Description",
                style: getTitleTextStyle(context, fontSize: 14),
              ),
              const Gap(4),
              Text(
                currentTask.discription,
                style: getBodyTextStyle(context, fontSize: 14),
              ),
              const Gap(15),
            ],

            // Subtasks checklist
            if (currentTask.subTasks != null &&
                currentTask.subTasks!.isNotEmpty) ...[
              Text(
                "Checklist",
                style: getTitleTextStyle(context, fontSize: 14),
              ),
              const Gap(6),
              ...List.generate(currentTask.subTasks!.length, (index) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    currentTask.subTasks![index],
                    style: TextStyle(
                      decoration: subTasksCompletedState[index]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: subTasksCompletedState[index]
                          ? Colors.grey
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  value: subTasksCompletedState[index],
                  activeColor: AppColors.primaryColor,
                  onChanged: (val) => _toggleSubTask(index, val),
                );
              }),
              const Gap(15),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentTask.isCompleted
                          ? Colors.orange
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      currentTask.isCompleted = !currentTask.isCompleted;
                      if (currentTask.isCompleted) {
                        if (subTasksCompletedState.isNotEmpty) {
                          subTasksCompletedState = List.filled(subTasksCompletedState.length, true);
                          currentTask.subTasksCompleted = subTasksCompletedState;
                        }
                        NotificationService.cancelNotification(currentTask.notificationId);
                      } else {
                        if (subTasksCompletedState.isNotEmpty) {
                          subTasksCompletedState = List.filled(subTasksCompletedState.length, false);
                          currentTask.subTasksCompleted = subTasksCompletedState;
                        }
                        NotificationService.scheduleTaskNotification(currentTask);
                      }
                      AppLocalStorage.casheTaskData(currentTask.id, currentTask);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      currentTask.isCompleted ? Icons.undo : Icons.check_circle,
                      color: Colors.white,
                    ),
                    label: Text(
                      currentTask.isCompleted
                          ? "Mark Pending"
                          : "Complete Task",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const Gap(10),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                  ),
                  onPressed: () {
                    final deletedTask = currentTask;
                    final messenger = ScaffoldMessenger.of(context);

                    NotificationService.cancelNotification(deletedTask.notificationId);
                    AppLocalStorage.taskBox.delete(deletedTask.id);
                    Navigator.pop(context);

                    messenger.showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 4),
                        backgroundColor: Colors.black87,
                        content: const Text(
                          'Task deleted 🗑️',
                          style: TextStyle(color: Colors.white),
                        ),
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: Colors.orangeAccent,
                          onPressed: () {
                            AppLocalStorage.casheTaskData(
                                deletedTask.id, deletedTask);
                            if (!deletedTask.isCompleted) {
                              NotificationService.scheduleTaskNotification(
                                  deletedTask);
                            }
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
