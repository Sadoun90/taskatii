import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/task_item.dart';
import 'package:taskatii/features/home/widgets/task_details_sheet.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String formattedDate = DateFormat.yMd().format(selectedDate);

    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar & Schedule',
          style: getTitleTextStyle(context, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: AppLocalStorage.taskBox.listenable(),
        builder: (context, Box<TaskModel> taskBox, child) {
          // Set of date strings that have tasks
          Set<String> taskDatesSet = taskBox.values.map((t) => t.date).toSet();

          List<TaskModel> tasksForDate = taskBox.values
              .where((task) => task.date == formattedDate)
              .toList();

          tasksForDate.sort((a, b) {
            if (a.isCompleted != b.isCompleted) {
              return a.isCompleted ? 1 : -1;
            }
            return a.startTime.compareTo(b.startTime);
          });

          // Month Grid Calculation
          DateTime firstDayOfMonth =
              DateTime(focusedMonth.year, focusedMonth.month, 1);
          int daysInMonth =
              DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
          int startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
          int totalGridCells = startingWeekday + daysInMonth;
          int totalRows = (totalGridCells / 7).ceil();
          int gridCount = totalRows * 7;

          return Column(
            children: [
              // Main Month Calendar Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Month Navigation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () {
                            setState(() {
                              focusedMonth = DateTime(
                                  focusedMonth.year, focusedMonth.month - 1, 1);
                            });
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(focusedMonth),
                          style: getTitleTextStyle(context, fontSize: 16),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedDate = DateTime.now();
                                  focusedMonth = DateTime.now();
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Today',
                                  style: getSmallTextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(4),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded),
                              onPressed: () {
                                setState(() {
                                  focusedMonth = DateTime(
                                      focusedMonth.year, focusedMonth.month + 1, 1);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(8),

                    // Weekday Titles Header (Sun, Mon, Tue...)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekDays.map((day) {
                        return SizedBox(
                          width: 38,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 16),

                    // Days Grid View (with Task Indicators directly inside calendar cells)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gridCount,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        int dayNum = index - startingWeekday + 1;
                        if (dayNum < 1 || dayNum > daysInMonth) {
                          return const SizedBox.shrink();
                        }

                        DateTime cellDate = DateTime(
                            focusedMonth.year, focusedMonth.month, dayNum);
                        String cellDateStr = DateFormat.yMd().format(cellDate);

                        bool isSelected = cellDate.year == selectedDate.year &&
                            cellDate.month == selectedDate.month &&
                            cellDate.day == selectedDate.day;

                        bool isToday = cellDate.year == DateTime.now().year &&
                            cellDate.month == DateTime.now().month &&
                            cellDate.day == DateTime.now().day;

                        bool hasTask = taskDatesSet.contains(cellDateStr);

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedDate = cellDate;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : (isToday
                                      ? AppColors.primaryColor.withValues(alpha: 0.15)
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(12),
                              border: isToday && !isSelected
                                  ? Border.all(
                                      color: AppColors.primaryColor, width: 1.5)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: (isSelected || isToday)
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                ),
                                const Gap(2),
                                // Task Dot directly inside Calendar Cell 📌
                                if (hasTask)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else
                                  const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Selected Date Header Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d').format(selectedDate),
                      style: getTitleTextStyle(context, fontSize: 15),
                    ),
                    const Spacer(),
                    Text(
                      '${tasksForDate.length} Tasks',
                      style: getSmallTextStyle(color: AppColors.primaryColor),
                    ),
                  ],
                ),
              ),
              const Gap(4),

              // Task List for Selected Date
              Expanded(
                child: tasksForDate.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                size: 54,
                                color: Colors.grey.shade400,
                              ),
                              const Gap(8),
                              Text(
                                'No tasks scheduled for this day',
                                style: getBodyTextStyle(context, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        itemCount: tasksForDate.length,
                        itemBuilder: (context, index) {
                          final task = tasksForDate[index];
                          return TaskItemWidget(
                            model: task,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    TaskDetailsSheet(task: task),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
