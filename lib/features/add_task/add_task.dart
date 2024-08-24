import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/CustomButton.dart';
import 'package:taskatii/features/home/home_view.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title',
                    style: getTitleTextStyle(
                        color: AppColors.blackColor, fontSize: 16),
                  ),
                ],
              ),
              Gap(2),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Enter title here',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.accentColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.accentColor)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.redColor)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.redColor))),
              ),
              Gap(20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note',
                    style: getTitleTextStyle(
                        color: AppColors.blackColor, fontSize: 16),
                  ),
                ],
              ),
              Gap(2),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Enter note here',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.accentColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.accentColor)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.redColor)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.redColor))),
              ),
              Gap(20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: getTitleTextStyle(
                        color: AppColors.blackColor, fontSize: 16),
                  ),
                ],
              ),
              Gap(2),
              TextFormField(
                decoration: InputDecoration(
                    hintText: '10/30/2023',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.accentColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.accentColor)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.redColor)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.redColor)),
                    suffixIcon: Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.blackColor,
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
                          color: AppColors.blackColor, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'End Time',
                      style: getTitleTextStyle(
                          color: AppColors.blackColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
              Gap(2),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: '02:30 AM',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.accentColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.accentColor)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.redColor)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.redColor)),
                          suffixIcon: Icon(Icons.timer_sharp)),
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: '02:45 AM',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.accentColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.accentColor)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.redColor)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.redColor)),
                          suffixIcon: Icon(Icons.timer_sharp)),
                    ),
                  ),
                ],
              ),
              Gap(20),
              Row(
                children: [
                  Column(
                    children: [
                      Text(
                        'Color',
                        style: getTitleTextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  CustomButton(
                      width: 150,
                      height: 50,
                      text: 'Create Task',
                      onPressed: () {})
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
