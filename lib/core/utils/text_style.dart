import 'package:flutter/material.dart';
import 'package:taskatii/core/utils/colors.dart';

TextStyle getTitleTextStyle(
    {double? fontSize, Color? color, FontWeight? fontWeight}) {
  return TextStyle(
    fontFamily: 'Poppins',
    color: color ?? AppColors.PrimaryColor,
    fontSize: fontSize ?? 20,
    fontWeight: fontWeight ?? FontWeight.w600,
  );
}

TextStyle getBodyTextStyle(
    {double? fontSize, Color? color, FontWeight? fontWeight}) {
  return TextStyle(
    fontFamily: 'Poppins',
    color: color ?? AppColors.PrimaryColor,
    fontSize: fontSize ?? 16,
  );
}

TextStyle getSmallTextStyle(
    {double? fontSize, Color? color, FontWeight? fontWeight}) {
  return TextStyle(
    fontFamily: 'Poppins',
    color: color ?? AppColors.accentColor,
    fontSize: fontSize ?? 14,
  );
}
