import 'package:flutter/material.dart';
import 'package:taskatii/core/utils/colors.dart';

TextStyle getTitleTextStyle(
  BuildContext context, {
  double? fontSize,
  Color? color,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontFamily: 'Poppins',
    color: color ?? Theme.of(context).colorScheme.onSurface,
    fontSize: fontSize ?? 20,
    fontWeight: fontWeight ?? FontWeight.w600,
  );
}

TextStyle getBodyTextStyle(
  BuildContext context, {
  double? fontSize,
  Color? color,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontFamily: 'Poppins',
    color: color ?? Theme.of(context).colorScheme.onSurface,
    fontSize: fontSize ?? 16,
    fontWeight: fontWeight ?? FontWeight.normal,
  );
}

TextStyle getSmallTextStyle({
  double? fontSize,
  Color? color,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontFamily: 'Poppins',
    color: color ?? AppColors.accentColor,
    fontSize: fontSize ?? 14,
  );
}
