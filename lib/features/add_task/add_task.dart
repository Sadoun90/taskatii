import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:taskatii/core/functions/navigation.dart';
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
  String StartTime = DateFormat('hh:mm a').format(DateTime.now());
  String EndTime =
      DateFormat('hh:mm a').format(DateTime.now().add(Duration(hours: 1)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Push(context, HomeView());
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.accentColor,
            )),
        centerTitle: true,
        title: Text(
          'Add Task',
          style: getTitleTextStyle(
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
                      color: AppColors.blackColor, fontSize: 15),
                ),
                Gap(2),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Ex : Go To School '),
                ),
                Gap(20),
                Text(
                  'Note',
                  style: getTitleTextStyle(
                      color: AppColors.blackColor, fontSize: 15),
                ),
                const Gap(2),
                TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(hintText: 'Add a Note '),
                ),
                Gap(20),
                Text(
                  'Date',
                  style: getTitleTextStyle(
                      color: AppColors.blackColor, fontSize: 15),
                ),
                TextFormField(
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030))
                        .then((value) {
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
                      hintStyle: getBodyTextStyle(color: AppColors.blackColor),
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: AppColors.PrimaryColor,
                      )),
                ),
                Gap(20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Start Time',
                        style: getTitleTextStyle(
                            color: AppColors.blackColor, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'End Time',
                        style: getTitleTextStyle(
                            color: AppColors.blackColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                Gap(2),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onTap: () {
                          showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now())
                              .then((value) {
                            if (value != null) {
                              setState(() {
                                StartTime = value.format(context);
                              });
                            }
                          });
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                            hintText: StartTime,
                            hintStyle:
                                getSmallTextStyle(color: AppColors.blackColor),
                            suffixIcon: Icon(
                              Icons.watch_later_outlined,
                              color: AppColors.PrimaryColor,
                            )),
                      ),
                    ),
                    Gap(10),
                    Expanded(
                      child: TextFormField(
                        onTap: () {
                          showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now())
                              .then((value) {
                            if (value != null) {
                              setState(() {
                                EndTime = value.format(context);
                              });
                            }
                          });
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                            hintText: EndTime,
                            hintStyle:
                                getSmallTextStyle(color: AppColors.blackColor),
                            suffixIcon: Icon(
                              Icons.watch_later_outlined,
                              color: AppColors.PrimaryColor,
                            )),
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
                                colorIndex = 0; // Corrected the state update
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
                                colorIndex = 1; // Corrected the state update
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
                                    : null),
                          ),
                          const Gap(5),
                          InkWell(
                            onTap: () {
                              setState(() {
                                colorIndex = 2; // Corrected the state update
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
                                    : null),
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.PrimaryColor,
                            foregroundColor: AppColors.whiteColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {},
                        child: Text(
                          'Create Task',
                          style: getTitleTextStyle(
                              fontSize: 15, color: AppColors.whiteColor),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
