import 'package:flutter/material.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';

class AppTheme {
  // ignore: non_constant_identifier_names
  static ThemeData LightTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.whiteColor,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.PrimaryColor,
        onSurface: AppColors.blackColor,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.whiteColor,
        headerForegroundColor: AppColors.PrimaryColor,
      ),
      timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors.whiteColor,
          dialBackgroundColor: AppColors.primaryColor,
          hourMinuteColor: AppColors.primaryColor,
          dayPeriodColor: AppColors.accentColor,
          hourMinuteTextColor: AppColors.darkColorScaffoldColor),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: getSmallTextStyle(),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.PrimaryColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.PrimaryColor)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.redcolor)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.redcolor)),
      ));

  // ignore: non_constant_identifier_names
  static ThemeData DarkTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.darkColorScaffoldColor,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkColorScaffoldColor,
        centerTitle: true,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.PrimaryColor,
        onSurface: AppColors.whiteColor,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.darkColorScaffoldColor,
        headerForegroundColor: AppColors.PrimaryColor,
      ),
      timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors.darkColorScaffoldColor,
          dialBackgroundColor: AppColors.primaryColor,
          hourMinuteColor: AppColors.primaryColor,
          dayPeriodColor: AppColors.accentColor,
          hourMinuteTextColor: AppColors.darkColorScaffoldColor),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: getSmallTextStyle(),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.PrimaryColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.PrimaryColor)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.redcolor)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.redcolor)),
      ));
}
