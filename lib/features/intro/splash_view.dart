import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/features/home/home_view.dart';
import 'package:taskatii/features/upload/upload_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    var box = Hive.box('userBox');
    Future.delayed(const Duration(seconds: 3), () {
      PushWithReplacement(context,(box.get('isUpload') ?? false) == true ? HomeView(): UploadView());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/logo.json'),
            Text(
              'Taskati',
              style: getTitleTextStyle(color: AppColors.PrimaryColor),
            ),
            const Gap(10),
            Text(
              'It\'s time to get organized',
              style: getSmallTextStyle(color: AppColors.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
