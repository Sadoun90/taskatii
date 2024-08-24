import 'package:flutter/material.dart';
import 'package:taskatii/core/utils/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key, this.width, this.height, required this.text, required this.onPressed, this.color,
  });

  final double ? width;
  final double ? height;
  final String text;
  final Function() onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50,
      width: width ?? 250,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.PrimaryColor,
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: onPressed,
          child: Text(text)),
    );
  }
}