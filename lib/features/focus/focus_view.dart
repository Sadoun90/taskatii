import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class FocusView extends StatefulWidget {
  const FocusView({super.key});

  @override
  State<FocusView> createState() => _FocusViewState();
}

class _FocusViewState extends State<FocusView> {
  int totalSeconds = 25 * 60; // 25 mins default
  int initialSeconds = 25 * 60;
  Timer? timer;
  bool isRunning = false;
  TaskModel? selectedTask;
  int completedSessions = 0;

  void startTimer() {
    if (timer != null) timer!.cancel();
    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (totalSeconds > 0) {
        setState(() {
          totalSeconds--;
        });
      } else {
        t.cancel();
        setState(() {
          isRunning = false;
          completedSessions++;
          totalSeconds = initialSeconds;
        });

        // Show completion snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('🎉 Focus session completed! Take a 5-minute break.'),
            ),
          );
        }
      }
    });
  }

  void pauseTimer() {
    if (timer != null) timer!.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    if (timer != null) timer!.cancel();
    setState(() {
      isRunning = false;
      totalSeconds = initialSeconds;
    });
  }

  void setDuration(int minutes) {
    if (timer != null) timer!.cancel();
    setState(() {
      initialSeconds = minutes * 60;
      totalSeconds = initialSeconds;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get minutesString =>
      (totalSeconds ~/ 60).toString().padLeft(2, '0');
  String get secondsString =>
      (totalSeconds % 60).toString().padLeft(2, '0');

  double get progress =>
      initialSeconds > 0 ? (initialSeconds - totalSeconds) / initialSeconds : 0;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Focus & Pomodoro',
          style: getTitleTextStyle(context, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Task Selector Card
              ValueListenableBuilder(
                valueListenable: AppLocalStorage.taskBox.listenable(),
                builder: (context, Box<TaskModel> taskBox, child) {
                  List<TaskModel> pendingTasks = taskBox.values
                      .where((t) => !t.isCompleted)
                      .toList();

                  return GestureDetector(
                    onTap: () {
                      if (pendingTasks.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No pending tasks. Add a task first!'),
                          ),
                        );
                        return;
                      }
                      showModalBottomSheet(
                        context: context,
                        backgroundColor:
                            isDark ? Colors.grey.shade900 : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (ctx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const Gap(16),
                                Text(
                                  'Select Task to Focus On',
                                  style: getTitleTextStyle(context, fontSize: 16),
                                ),
                                const Gap(12),
                                ...pendingTasks.map((t) {
                                  return ListTile(
                                    leading: Icon(
                                      Icons.radio_button_unchecked,
                                      color: AppColors.primaryColor,
                                    ),
                                    title: Text(
                                      t.title,
                                      style: getBodyTextStyle(context),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedTask = t;
                                      });
                                      Navigator.pop(ctx);
                                    },
                                  );
                                }),
                                const Gap(8),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.task_alt,
                            color: selectedTask != null
                                ? AppColors.primaryColor
                                : Colors.grey,
                            size: 20,
                          ),
                          const Gap(10),
                          Expanded(
                            child: Text(
                              selectedTask?.title ??
                                  'Tap to select a task to focus on...',
                              style: getBodyTextStyle(
                                context,
                                color: selectedTask != null
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Gap(24),


              // Duration Preset Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [15, 25, 45].map((mins) {
                    bool isSelected = initialSeconds == mins * 60;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text('$mins Mins'),
                        selected: isSelected,
                        selectedColor: AppColors.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => setDuration(mins),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Gap(30),

              // Circular Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$minutesString:$secondsString',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        isRunning ? 'STAY FOCUSED 🔥' : 'READY TO START',
                        style: getSmallTextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(36),

              // Action Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: resetTimer,
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                  const Gap(20),
                  ElevatedButton(
                    onPressed: isRunning ? pauseTimer : startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isRunning ? Colors.orange : AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRunning ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                        const Gap(8),
                        Text(
                          isRunning ? 'PAUSE' : 'START',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(30),

              // Sessions Stats Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$completedSessions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Sessions Done Today',
                          style: getSmallTextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.grey.shade400),
                    Column(
                      children: [
                        Text(
                          '${completedSessions * (initialSeconds ~/ 60)}m',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Total Focus Time',
                          style: getSmallTextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
