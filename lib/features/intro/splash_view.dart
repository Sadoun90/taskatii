import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/services/notification_service.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/features/main_layout/main_layout.dart';
import 'package:taskatii/features/intro/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 4000), () async {
      if (!mounted) return;

      bool isUpload =
          AppLocalStorage.getCachedData(AppLocalStorage.KIsUpload) ?? false;

      if (!isUpload) {
        // First launch: show onboarding
        PushWithReplacement(context, const OnboardingView());
      } else {
        // Check if app was launched by tapping a notification
        final launchDetails =
            await NotificationService.getAppLaunchNotificationDetails();
        if (launchDetails != null && launchDetails.payload != null) {
          NotificationService.handleNotificationPayload(launchDetails.payload);
        } else {
          if (mounted) {
            PushWithReplacement(context, const MainLayout());
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/logo.json', height: 200),
            const Gap(15),
            Text(
              'Taskatii',
              style: getTitleTextStyle(
                context,
                color: AppColors.primaryColor,
                fontSize: 26,
              ),
            ),
            const Gap(10),
            Text(
              'It\'s time to get organized 🚀',
              style: getSmallTextStyle(
                color: AppColors.accentColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
