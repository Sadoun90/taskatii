import 'package:flutter/material.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.whiteColor,
      appBarTheme:
          AppBarTheme(backgroundColor: AppColors.whiteColor, centerTitle: true),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        onSurface: AppColors.blackColor,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.whiteColor,
        headerForegroundColor: AppColors.primaryColor,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.whiteColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: getSmallTextStyle(),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            )),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            )),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.redcolor,
            )),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.redcolor,
            )),
      ));

  static ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.darkColorScaffoldColor,
      appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkColorScaffoldColor, centerTitle: true),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        onSurface: AppColors.whiteColor,
      ),
      datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColors.darkColorScaffoldColor,
          headerForegroundColor: AppColors.primaryColor),
      timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors.darkColorScaffoldColor,
          dialBackgroundColor: AppColors.accentColor,
          hourMinuteTextColor: AppColors.primaryColor,
          dayPeriodColor: AppColors.accentColor,
          hourMinuteColor: AppColors.accentColor,
          dayPeriodTextColor: AppColors.primaryColor),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: getSmallTextStyle(),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            )),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            )),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.redcolor,
            )),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.redcolor,
            )),
      ));
}
