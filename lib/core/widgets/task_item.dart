import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsetsDirectional.only(bottom: 10, start: 5, end: 5),
      decoration: BoxDecoration(
          color: AppColors.PrimaryColor,
          borderRadius: BorderRadius.circular(13)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'flutter Task',
                  style: getTitleTextStyle(
                      color: AppColors.whiteColor, fontSize: 16),
                ),
                Gap(10),
                Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      color: AppColors.whiteColor,
                      size: 20,
                    ),
                    Gap(10),
                    Text(
                      '10:00 Am - 10:00 Pm',
                      style: getSmallTextStyle(
                          color: AppColors.whiteColor, fontSize: 12),
                    ),
                  ],
                ),
                Gap(10),
                Text(
                  'Flutter Task',
                  style: getBodyTextStyle(
                      color: AppColors.whiteColor, fontSize: 16),
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            width: 1,
            color: AppColors.whiteColor,
          ),
          Gap(5),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              'TODO',
              style: getTitleTextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
