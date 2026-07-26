import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/services/notification_service.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class AddTask extends StatefulWidget {
  final TaskModel? task;

  const AddTask({super.key, this.task});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String taskDate = DateFormat.yMd().format(DateTime.now());
  String startTime = DateFormat('hh:mm a').format(DateTime.now());
  String endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(hours: 1)));

  String selectedCategory = 'General';
  int selectedPriority = 1; // 0: High, 1: Medium, 2: Low
  String selectedRepeat = 'None'; // 'None', 'Daily', 'Weekly', 'Monthly'

  final titleController = TextEditingController();
  final noteController = TextEditingController();
  final subTaskController = TextEditingController();

  List<String> subTasks = [];
  List<bool> subTasksCompleted = [];

  final List<Map<String, dynamic>> categories = [
    {'name': 'General', 'icon': Icons.task_alt},
    {'name': 'Work', 'icon': Icons.work_outline},
    {'name': 'Personal', 'icon': Icons.person_outline},
    {'name': 'Study', 'icon': Icons.menu_book_outlined},
    {'name': 'Health', 'icon': Icons.fitness_center},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined},
  ];

  final List<String> repeatOptions = ['None', 'Daily', 'Weekly', 'Monthly'];

  bool isReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      final t = widget.task!;
      titleController.text = t.title;
      noteController.text = t.discription;
      taskDate = t.date;
      startTime = t.startTime;
      endTime = t.endTime;
      selectedCategory = t.category ?? 'General';
      selectedPriority = t.priority ?? 1;
      selectedRepeat = t.isRepeat ?? 'None';
      isReminderEnabled = t.notificationId != null;
      if (t.subTasks != null) {
        subTasks = List<String>.from(t.subTasks!);
        subTasksCompleted = t.subTasksCompleted != null
            ? List<bool>.from(t.subTasksCompleted!)
            : List.filled(subTasks.length, false);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    subTaskController.dispose();
    super.dispose();
  }

  bool get isEditMode => widget.task != null;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          isEditMode ? 'Edit Task' : 'Add Task',
          style: getTitleTextStyle(
            context,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              Text(
                'Title',
                style: getTitleTextStyle(
                  context,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const Gap(6),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Go to gym or finish report',
                ),
              ),
              const Gap(16),

              // Category Selector
              Text(
                'Category',
                style: getTitleTextStyle(
                  context,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const Gap(6),
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    bool isSelected = selectedCategory == cat['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        avatar: Icon(
                          cat['icon'],
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                        label: Text(
                          cat['name'],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedCategory = cat['name'];
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const Gap(16),

              // Priority Selector
              Text(
                'Priority',
                style: getTitleTextStyle(
                  context,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const Gap(6),
              Row(
                children: [
                  _buildPriorityChip(0, "High 🔴", AppColors.highPriority),
                  const Gap(10),
                  _buildPriorityChip(1, "Medium 🟡", AppColors.mediumPriority),
                  const Gap(10),
                  _buildPriorityChip(2, "Low 🟢", AppColors.lowPriority),
                ],
              ),
              const Gap(16),

              // Repeat Selector
              Text(
                'Repeat Rule 🔄',
                style: getTitleTextStyle(
                  context,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const Gap(6),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: repeatOptions.length,
                  itemBuilder: (context, index) {
                    final option = repeatOptions[index];
                    bool isSelected = selectedRepeat == option;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          option,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedRepeat = option;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const Gap(16),

              // Note Field
              Text(
                'Note',
                style: getTitleTextStyle(
                  context,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const Gap(6),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add additional details or notes...',
                ),
              ),
              const Gap(16),

              // Sub-tasks Section
              Text(
                'Sub-Tasks (Checklist)',
                style: getTitleTextStyle(
                  context,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const Gap(6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: subTaskController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            subTasks.add(val.trim());
                            subTasksCompleted.add(false);
                            subTaskController.clear();
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Add a sub-task step...',
                      ),
                    ),
                  ),
                  const Gap(10),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      if (subTaskController.text.trim().isNotEmpty) {
                        setState(() {
                          subTasks.add(subTaskController.text.trim());
                          subTasksCompleted.add(false);
                          subTaskController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  )
                ],
              ),
              if (subTasks.isNotEmpty) ...[
                const Gap(10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subTasks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        dense: true,
                        title: Text(subTasks[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              subTasks.removeAt(index);
                              subTasksCompleted.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
              const Gap(16),

              // Date Field
              Text(
                'Date',
                style: getTitleTextStyle(
                  context,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const Gap(6),
              TextFormField(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        taskDate = DateFormat.yMd().format(value);
                      });
                    }
                  });
                },
                readOnly: true,
                decoration: InputDecoration(
                  hintText: taskDate,
                  hintStyle:
                      getBodyTextStyle(context, color: AppColors.primaryColor),
                  suffixIcon: Icon(
                    Icons.calendar_month,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const Gap(16),

              // Times Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: getTitleTextStyle(
                            context,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        const Gap(6),
                        TextFormField(
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  startTime = value.format(context);
                                });
                              }
                            });
                          },
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: startTime,
                            hintStyle: getSmallTextStyle(
                                color: AppColors.primaryColor),
                            suffixIcon: Icon(
                              Icons.access_time,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: getTitleTextStyle(
                            context,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        const Gap(6),
                        TextFormField(
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  endTime = value.format(context);
                                });
                              }
                            });
                          },
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: endTime,
                            hintStyle: getSmallTextStyle(
                                color: AppColors.primaryColor),
                            suffixIcon: Icon(
                              Icons.access_time,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),

              // Enable Alarm Notification Toggle Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isReminderEnabled
                        ? AppColors.primaryColor
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                    width: isReminderEnabled ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isReminderEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_outlined,
                            color: isReminderEnabled
                                ? AppColors.primaryColor
                                : Colors.grey,
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Alarm Notification 🔔',
                                  overflow: TextOverflow.ellipsis,
                                  style: getTitleTextStyle(
                                    context,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  isReminderEnabled
                                      ? 'Alarm enabled for this task'
                                      : 'No alarm (optional)',
                                  overflow: TextOverflow.ellipsis,
                                  style: getSmallTextStyle(
                                    color: isReminderEnabled
                                        ? AppColors.primaryColor
                                        : Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Switch(
                      value: isReminderEnabled,
                      activeTrackColor: AppColors.primaryColor,
                      onChanged: (val) {
                        setState(() {
                          isReminderEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Gap(20),

              // Save / Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.redcolor,
                          content: const Text('Please enter a task title'),
                        ),
                      );
                      return;
                    }

                    if (subTaskController.text.trim().isNotEmpty) {
                      subTasks.add(subTaskController.text.trim());
                      subTasksCompleted.add(false);
                      subTaskController.clear();
                    }

                    String id = isEditMode
                        ? widget.task!.id
                        : '${titleController.text}-${DateTime.now().millisecondsSinceEpoch}';

                    int? notifId;
                    if (isReminderEnabled) {
                      notifId = isEditMode && widget.task!.notificationId != null
                          ? widget.task!.notificationId!
                          : (DateTime.now().microsecondsSinceEpoch % 2147483647);
                    } else {
                      notifId = null;
                      if (isEditMode && widget.task!.notificationId != null) {
                        NotificationService.cancelNotification(widget.task!.notificationId);
                      }
                    }

                    TaskModel model = TaskModel(
                      id: id,
                      title: titleController.text.trim(),
                      discription: noteController.text.trim(),
                      date: taskDate,
                      startTime: startTime,
                      endTime: endTime,
                      color: selectedPriority, // map priority to color for display
                      isCompleted: isEditMode ? widget.task!.isCompleted : false,
                      category: selectedCategory,
                      priority: selectedPriority,
                      subTasks: subTasks,
                      subTasksCompleted: subTasksCompleted,
                      isRepeat: selectedRepeat,
                      notificationId: notifId,
                    );

                    AppLocalStorage.casheTaskData(id, model);

                    if (isReminderEnabled) {
                      NotificationService.scheduleTaskNotification(model);
                    }

                    Navigator.pop(context);
                  },
                  child: Text(
                    isEditMode ? 'Update Task' : 'Create Task',
                    style: getTitleTextStyle(
                      context,
                      fontSize: 15,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int index, String label, Color color) {
    bool isSelected = selectedPriority == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPriority = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
