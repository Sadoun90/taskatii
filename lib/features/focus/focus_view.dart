import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/services/notification_service.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class FocusTimerController {
  static int totalSeconds = 25 * 60; // 25 mins default
  static int initialSeconds = 25 * 60;
  static Timer? timer;
  static bool isRunning = false;
  static DateTime? endTime;
  static TaskModel? selectedTask;
  static int completedSessions = 0;

  static final List<void Function()> _listeners = [];

  static void addListener(void Function() listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  static void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }

  /// Public wrapper to notify all UI listeners (e.g., from BottomSheets)
  static void notifyAll() => _notifyListeners();

  static void checkSelectedTaskValid() {
    if (selectedTask != null) {
      final exists = AppLocalStorage.taskBox.containsKey(selectedTask!.id);
      if (!exists) {
        cancelTimer();
        selectedTask = null;
        _notifyListeners();
      }
    }
  }

  static Future<void> startTimer() async {
    timer?.cancel();
    isRunning = true;
    endTime = DateTime.now().add(Duration(seconds: totalSeconds));

    await NotificationService.requestNotificationPermission();

    await NotificationService.scheduleFocusEndNotification(
      durationSeconds: totalSeconds,
      taskTitle: selectedTask?.title,
    );

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (endTime == null) return;
      final diff = endTime!.difference(DateTime.now()).inSeconds;
      if (diff > 0) {
        totalSeconds = diff;
        _notifyListeners();
      } else {
        t.cancel();
        isRunning = false;
        completedSessions++;
        totalSeconds = initialSeconds;
        endTime = null;
        _notifyListeners();

        NotificationService.showFocusCompleteNotification(
          taskTitle: selectedTask?.title,
        );
      }
    });
    _notifyListeners();
  }

  static void pauseTimer() {
    timer?.cancel();
    isRunning = false;
    endTime = null;
    NotificationService.cancelFocusNotification();
    _notifyListeners();
  }

  static void cancelTimer() {
    timer?.cancel();
    isRunning = false;
    endTime = null;
    totalSeconds = initialSeconds;
    NotificationService.cancelFocusNotification();
    _notifyListeners();
  }

  static void setDuration(int minutes) {
    timer?.cancel();
    initialSeconds = minutes * 60;
    totalSeconds = initialSeconds;
    isRunning = false;
    endTime = null;
    NotificationService.cancelFocusNotification();
    _notifyListeners();
  }
}

class FocusView extends StatefulWidget {
  const FocusView({super.key});

  @override
  State<FocusView> createState() => _FocusViewState();
}

class _FocusViewState extends State<FocusView> {
  @override
  void initState() {
    super.initState();
    FocusTimerController.addListener(_onTimerStateChanged);
    FocusTimerController.checkSelectedTaskValid();

    // Recalculate remaining seconds if timer is running in background
    if (FocusTimerController.isRunning && FocusTimerController.endTime != null) {
      final remaining = FocusTimerController.endTime!.difference(DateTime.now()).inSeconds;
      if (remaining > 0) {
        FocusTimerController.totalSeconds = remaining;
      } else {
        FocusTimerController.cancelTimer();
      }
    }
  }

  @override
  void dispose() {
    FocusTimerController.removeListener(_onTimerStateChanged);
    super.dispose();
  }

  void _onTimerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String get minutesString =>
      (FocusTimerController.totalSeconds ~/ 60).toString().padLeft(2, '0');
  String get secondsString =>
      (FocusTimerController.totalSeconds % 60).toString().padLeft(2, '0');

  double get progress => FocusTimerController.initialSeconds > 0
      ? (FocusTimerController.initialSeconds - FocusTimerController.totalSeconds) /
          FocusTimerController.initialSeconds
      : 0;

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
                            duration: Duration(seconds: 2),
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
                                // None / General Focus Option to reset task selection
                                ListTile(
                                  leading: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.redAccent,
                                  ),
                                  title: Text(
                                    'None (General Focus Timer)',
                                    style: getBodyTextStyle(
                                      context,
                                      color: FocusTimerController.selectedTask == null
                                          ? Colors.redAccent
                                          : (isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600),
                                    ),
                                  ),
                                  onTap: () {
                                    FocusTimerController.selectedTask = null;
                                    if (FocusTimerController.isRunning &&
                                        FocusTimerController.endTime != null) {
                                      int remaining = FocusTimerController.endTime!
                                          .difference(DateTime.now())
                                          .inSeconds;
                                      if (remaining > 0) {
                                        NotificationService.scheduleFocusEndNotification(
                                          durationSeconds: remaining,
                                          taskTitle: null,
                                        );
                                      }
                                    }
                                    FocusTimerController.notifyAll();
                                    Navigator.pop(ctx);
                                  },
                                ),
                                const Divider(height: 12),
                                ...pendingTasks.map((t) {
                                  final bool isChosen =
                                      FocusTimerController.selectedTask?.id == t.id;
                                  return ListTile(
                                    leading: Icon(
                                      isChosen
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: AppColors.primaryColor,
                                    ),
                                    title: Text(
                                      t.title,
                                      style: getBodyTextStyle(
                                        context,
                                        color: isChosen
                                            ? AppColors.primaryColor
                                            : (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black87),
                                      ),
                                    ),
                                    onTap: () {
                                      FocusTimerController.selectedTask = t;
                                      if (FocusTimerController.isRunning &&
                                          FocusTimerController.endTime != null) {
                                        int remaining = FocusTimerController.endTime!
                                            .difference(DateTime.now())
                                            .inSeconds;
                                        if (remaining > 0) {
                                          NotificationService.scheduleFocusEndNotification(
                                            durationSeconds: remaining,
                                            taskTitle: t.title,
                                          );
                                        }
                                      }
                                      FocusTimerController.notifyAll();
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
                            color: FocusTimerController.selectedTask != null
                                ? AppColors.primaryColor
                                : Colors.grey,
                            size: 20,
                          ),
                          const Gap(10),
                          Expanded(
                            child: Text(
                              FocusTimerController.selectedTask?.title ??
                                  'Tap to select a task to focus on...',
                              style: getBodyTextStyle(
                                context,
                                color: FocusTimerController.selectedTask != null
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (FocusTimerController.selectedTask != null)
                            InkWell(
                              onTap: () {
                                FocusTimerController.selectedTask = null;
                                if (FocusTimerController.isRunning &&
                                    FocusTimerController.endTime != null) {
                                  int remaining = FocusTimerController.endTime!
                                      .difference(DateTime.now())
                                      .inSeconds;
                                  if (remaining > 0) {
                                    NotificationService.scheduleFocusEndNotification(
                                      durationSeconds: remaining,
                                      taskTitle: null,
                                    );
                                  }
                                }
                                FocusTimerController.notifyAll();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                              ),
                            )
                          else
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
                    bool isSelected =
                        FocusTimerController.initialSeconds == mins * 60;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text('$mins Mins'),
                        selected: isSelected,
                        selectedColor: AppColors.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => FocusTimerController.setDuration(mins),
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
                        FocusTimerController.isRunning
                            ? 'STAY FOCUSED 🔥'
                            : 'READY TO START',
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
                    onPressed: FocusTimerController.cancelTimer,
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                  const Gap(20),
                  ElevatedButton(
                    onPressed: FocusTimerController.isRunning
                        ? FocusTimerController.pauseTimer
                        : FocusTimerController.startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FocusTimerController.isRunning
                          ? Colors.orange
                          : AppColors.primaryColor,
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
                          FocusTimerController.isRunning
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                        const Gap(8),
                        Text(
                          FocusTimerController.isRunning ? 'PAUSE' : 'START',
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
                          '${FocusTimerController.completedSessions}',
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
                          '${FocusTimerController.completedSessions * (FocusTimerController.initialSeconds ~/ 60)}m',
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
