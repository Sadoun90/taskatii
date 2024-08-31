import 'dart:math';

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/task_item.dart';
import 'package:taskatii/features/home/widgets/home_header_widget.dart';
import 'package:taskatii/features/home/widgets/today_header.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String selectDate = DateFormat.yMd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    String name = AppLocalStorage.getCachedData(AppLocalStorage.KName) ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              HomeHeaderWidget(
                  name: name), // Pass the name to the header widget
              const Gap(15),
              const TodayHeader(),
              const Gap(20),
              DatePicker(
                DateTime.now().subtract(const Duration(days: 3)),
                height: 100,
                width: 80,
                initialSelectedDate: DateTime.now(),
                selectionColor: AppColors.PrimaryColor,
                dateTextStyle: getBodyTextStyle(context, fontSize: 18),
                monthTextStyle: getBodyTextStyle(context, fontSize: 14),
                dayTextStyle: getBodyTextStyle(context, fontSize: 14),
                selectedTextColor: Colors.white,
                onDateChange: (date) {
                  setState(() {
                    selectDate = DateFormat.yMd().format(date);
                  });
                },
              ),
              const Gap(20),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: AppLocalStorage.taskBox.listenable(),
                  builder: (context, taskBox, child) {
                    List<TaskModel> tasks = [];

                    taskBox.keys.forEach((key) {
                      if (selectDate ==
                          AppLocalStorage.getCacheTaskdData(key)?.date) {
                        tasks.add(AppLocalStorage.getCacheTaskdData(key)!);
                      }
                    });

                    return tasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset('assets/empty.json'),
                                const Gap(10),
                                Text(
                                  'No Task Found',
                                  style: getBodyTextStyle(context,
                                      color: AppColors.PrimaryColor),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                key: UniqueKey(),
                                background: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.white),
                                      Text(
                                        'Complete Task',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                secondaryBackground: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.redcolor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.delete, color: Colors.white),
                                      Text(
                                        'Delete Task',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onDismissed: (direction) {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    // Delete task
                                    taskBox.delete(tasks[index].id);
                                  } else {
                                    // Complete task
                                    taskBox.put(
                                      tasks[index].id,
                                      TaskModel(
                                        id: tasks[index].id,
                                        title: tasks[index].title,
                                        discription: tasks[index].discription,
                                        date: tasks[index].date,
                                        startTime: tasks[index].startTime,
                                        endTime: tasks[index].endTime,
                                        color: 3,
                                        isCompleted: true,
                                      ),
                                    );
                                  }
                                },
                                child: TaskItemWidget(model: tasks[index]),
                              );
                            },
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
