import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget({
    super.key,
    required this.model,
  });

  final TaskModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsetsDirectional.only(bottom: 10, start: 5, end: 5),
      decoration: BoxDecoration(
        color: model.color == 0
            ? AppColors.PrimaryColor
            : model.color == 1
                ? AppColors.orangeColor
                : model.color == 2
                    ? AppColors.redcolor
                    : Colors.green,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: getTitleTextStyle(
                    context,
                    color: AppColors.whiteColor,
                    fontSize: 16,
                  ),
                ),
                const Gap(10),
                Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      color: AppColors.whiteColor,
                      size: 20,
                    ),
                    const Gap(10),
                    Text(
                      '${model.startTime}-${model.endTime}',
                      style: getSmallTextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Text(
                  model.discription,
                  style: getBodyTextStyle(
                    context,
                    color: AppColors.whiteColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            width: 1,
            color: AppColors.whiteColor,
          ),
          const Gap(5),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              model.isCompleted ? "COMPLETED" : "TODO",
              style: getTitleTextStyle(
                context,
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
