import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/features/home/page/home_view.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  int colorIndex = 0;
  String taskDate = DateFormat.yMd().format(DateTime.now());
  String startTime = DateFormat('hh:mm a').format(DateTime.now());
  String endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(hours: 1)));

  final titleController = TextEditingController();
  final noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Push(context, const HomeView());
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Add Task',
          style: getTitleTextStyle(
            context,
            color: AppColors.PrimaryColor,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: getTitleTextStyle(
                    context,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                const Gap(2),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Ex : Go To School',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const Gap(20),
                Text(
                  'Note',
                  style: getTitleTextStyle(
                    context,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                const Gap(2),
                TextFormField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add a Note',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const Gap(20),
                Text(
                  'Date',
                  style: getTitleTextStyle(
                    context,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                TextFormField(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
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
                        getBodyTextStyle(context, color: AppColors.accentColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.PrimaryColor,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month,
                      color: AppColors.PrimaryColor,
                    ),
                  ),
                ),
                const Gap(20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Start Time',
                        style: getTitleTextStyle(
                          context,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'End Time',
                        style: getTitleTextStyle(
                          context,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(2),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
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
                          hintStyle:
                              getSmallTextStyle(color: AppColors.accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.PrimaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.PrimaryColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.PrimaryColor,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: Icon(
                            Icons.watch_later_outlined,
                            color: AppColors.PrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: TextFormField(
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
                          hintStyle:
                              getSmallTextStyle(color: AppColors.accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.PrimaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.PrimaryColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.PrimaryColor,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: Icon(
                            Icons.watch_later_outlined,
                            color: AppColors.PrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                colorIndex = 0;
                              });
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.PrimaryColor,
                              child: colorIndex == 0
                                  ? Icon(
                                      Icons.check,
                                      color: AppColors.whiteColor,
                                    )
                                  : null,
                            ),
                          ),
                          const Gap(5),
                          InkWell(
                            onTap: () {
                              setState(() {
                                colorIndex = 1;
                              });
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.orangeColor,
                              child: colorIndex == 1
                                  ? Icon(
                                      Icons.check,
                                      color: AppColors.whiteColor,
                                    )
                                  : null,
                            ),
                          ),
                          const Gap(5),
                          InkWell(
                            onTap: () {
                              setState(() {
                                colorIndex = 2;
                              });
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.redcolor,
                              child: colorIndex == 2
                                  ? Icon(
                                      Icons.check,
                                      color: AppColors.whiteColor,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.PrimaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        String id = '${titleController.text}-${DateTime.now()}';
                        AppLocalStorage.casheTaskData(
                          id,
                          TaskModel(
                            id: id,
                            title: titleController.text,
                            discription: noteController.text,
                            date: taskDate,
                            startTime: startTime,
                            endTime: endTime,
                            color: colorIndex,
                            isCompleted: false,
                          ),
                        );
                        PushWithReplacement(context, const HomeView());
                      },
                      child: Text(
                        'Create Task',
                        style: getTitleTextStyle(
                          context,
                          fontSize: 15,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
