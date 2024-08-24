import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/CustomButton.dart';
import 'package:taskatii/features/add_task/add_task.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box('userBox');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Text('Hello, ${box.get('name')}',
                          style: getTitleTextStyle()),
                      Text(
                        'Have a nice day',
                        style: getBodyTextStyle(color: AppColors.accentColor),
                      ),
                    ],
                  ),
                  Spacer(),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.PrimaryColor,
                    backgroundImage: (box.get('image') != null)
                        ? FileImage(File(box.get('image')!))
                        : const NetworkImage(
                            'https://th.bing.com/th/id/OIP.Wim1Ar6paI5-FdmrOedMMAHaHa?w=191&h=191&c=7&r=0&o=5&dpr=1.3&pid=1.7'),
                  )
                ],
              ),
              Gap(50),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                        text: 'Maintain a Task',
                        onPressed: () {
                          Push(context, AddTask());
                        })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
