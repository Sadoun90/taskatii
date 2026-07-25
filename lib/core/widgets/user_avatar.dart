import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taskatii/core/utils/colors.dart';

class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const UserAvatar({
    super.key,
    this.imagePath,
    this.radius = 30,
    this.onTap,
    this.onLongPress,
  });

  bool get _hasValidImage {
    if (imagePath == null || imagePath!.trim().isEmpty) return false;
    try {
      final file = File(imagePath!);
      return file.existsSync();
    } catch (_) {
      return false;
    }
  }

  static void showImagePreview(BuildContext context, String? imagePath) {
    bool hasValidImage = false;
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      try {
        hasValidImage = File(imagePath).existsSync();
      } catch (_) {}
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 120,
                  backgroundColor: AppColors.primaryColor,
                  backgroundImage:
                      hasValidImage ? FileImage(File(imagePath!)) : null,
                  child: !hasValidImage
                      ? const Icon(
                          Icons.person,
                          size: 130,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tap anywhere to close ✖',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
      backgroundImage: _hasValidImage ? FileImage(File(imagePath!)) : null,
      child: !_hasValidImage
          ? Icon(
              Icons.person,
              size: radius * 1.1,
              color: AppColors.primaryColor,
            )
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress ?? () => showImagePreview(context, imagePath),
      child: avatar,
    );
  }
}
