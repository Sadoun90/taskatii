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
  bool isCalendarExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String formattedDate = DateFormat.yMd().format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar & Schedule',
          style: getTitleTextStyle(context, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Collapsible Date Picker Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isCalendarExpanded = !isCalendarExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                          overflow: TextOverflow.ellipsis,
                          style: getTitleTextStyle(context, fontSize: 14),
                        ),
                      ),
                      const Gap(6),
                      if (selectedDate.day == DateTime.now().day &&
                          selectedDate.month == DateTime.now().month &&
                          selectedDate.year == DateTime.now().year) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
                        const Gap(6),
                      ],
                      Icon(
                        isCalendarExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
                if (isCalendarExpanded) ...[
                  const Divider(height: 16),
                  CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (newDate) {
                      setState(() {
                        selectedDate = newDate;
                        isCalendarExpanded = false;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          const Gap(4),

          // Task List for Selected Date
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: AppLocalStorage.taskBox.listenable(),
              builder: (context, Box<TaskModel> taskBox, child) {
                List<TaskModel> tasksForDate = taskBox.values
                    .where((task) => task.date == formattedDate)
                    .toList();

                if (tasksForDate.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const Gap(12),
                          Text(
                            'No tasks scheduled for this day',
                            style: getBodyTextStyle(context, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          builder: (context) => TaskDetailsSheet(task: task),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
