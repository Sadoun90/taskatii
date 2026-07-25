import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/features/profile/profile_view.dart';

class HomeHeaderWidget extends StatefulWidget {
  const HomeHeaderWidget({
    super.key,
  });

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget> {
  String? path;
  String name = '';
  @override
  void initState() {
    super.initState();
    path = AppLocalStorage.getCachedData(AppLocalStorage.KImage);
    name = AppLocalStorage.getCachedData(AppLocalStorage.KName) ?? '';
  }

  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${AppLocalStorage.getCachedData(AppLocalStorage.KName)}',
              style: getTitleTextStyle(context, color: AppColors.primaryColor),
            ),
            Text(
              'Have a nice Day',
              style: getBodyTextStyle(
                color: AppColors.accentColor,
                context,
              ),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            Push(context, const ProfileView());
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryColor,
            backgroundImage: AppLocalStorage.getCachedData(
                        AppLocalStorage.KImage) !=
                    null
                ? FileImage(
                    File(AppLocalStorage.getCachedData(AppLocalStorage.KImage)))
                : const AssetImage('assets/user.png'),
          ),
        )
      ],
    );
  }
}
