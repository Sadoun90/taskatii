import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/features/profile/profile_view.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(
                'Hello, ${AppLocalStorage.getCachedData(AppLocalStorage.KName)}',
                style: getBodyTextStyle(
                    color: AppColors.PrimaryColor, fontSize: 16)),
            Text(
              'Have a nice day',
              style: getSmallTextStyle(color: AppColors.accentColor),
            ),
          ],
        ),
        Spacer(),
        InkWell(
          onTap: () {
            Push(context, ProfileView());
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.PrimaryColor,
            backgroundImage: (AppLocalStorage.getCachedData(
                        AppLocalStorage.KImage) !=
                    null)
                ? FileImage(
                    File(AppLocalStorage.getCachedData(AppLocalStorage.KImage)))
                : const NetworkImage(
                    'https://th.bing.com/th/id/OIP.Wim1Ar6paI5-FdmrOedMMAHaHa?w=191&h=191&c=7&r=0&o=5&dpr=1.3&pid=1.7'),
          ),
        )
      ],
    );
  }
}
