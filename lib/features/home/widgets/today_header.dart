import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/CustomButton.dart';
import 'package:taskatii/features/add_task/add_task.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: getTitleTextStyle(context,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Today',
                style: getTitleTextStyle(context,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        CustomButton(
            width: 140,
            text: '+ Add Task',
            onPressed: () {
              Push(context, const AddTask());
            })
      ],
    );
  }
}
