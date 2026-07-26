import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/user_avatar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  void _pickImage(bool isCamera) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final ext = pickedFile.path.contains('.') ? pickedFile.path.split('.').last : 'png';
        final newPath = '${appDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';

        // Clean up old avatar file if present
        String? oldPath = AppLocalStorage.getCachedData(AppLocalStorage.KImage);
        if (oldPath != null) {
          try {
            final oldFile = File(oldPath);
            if (oldFile.existsSync()) oldFile.deleteSync();
          } catch (_) {}
        }

        final permanentFile = await File(pickedFile.path).copy(newPath);

        // Clear image cache so Flutter renders the newly selected profile image immediately
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        AppLocalStorage.casheData(AppLocalStorage.KImage, permanentFile.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.redcolor,
            content: Text('Error selecting image: $e'),
          ),
        );
      }
    }
  }

  void _showImagePickerSheet(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Profile Image',
                style: getTitleTextStyle(context, fontSize: 16),
              ),
              const Gap(20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryColor),
                title: const Text('Take a photo (Camera)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(true);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primaryColor),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    TextEditingController nameController =
        TextEditingController(text: currentName);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          title: Text(
            'Edit Name',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: "Enter your name",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  AppLocalStorage.casheData(
                      AppLocalStorage.KName, nameController.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name updated successfully!')),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  BoxDecoration _cardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      ),
      boxShadow: isDarkMode
          ? []
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: AppLocalStorage.userBox.listenable(),
      builder: (context, box, child) {
        String name = AppLocalStorage.getCachedData(AppLocalStorage.KName) ?? '';
        String? imagePath = AppLocalStorage.getCachedData(AppLocalStorage.KImage);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Profile Settings',
              style: getTitleTextStyle(context, color: AppColors.primaryColor),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar Stack
                Center(
                  child: Stack(
                    children: [
                      UserAvatar(
                        imagePath: imagePath,
                        radius: 60,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => _showImagePickerSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                // Name Title
                Text(
                  name.isNotEmpty ? name : 'User Profile',
                  style: getTitleTextStyle(
                    context,
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const Gap(24),

                // User Name Edit Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(isDarkMode),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: AppColors.primaryColor),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Display Name',
                              style: getSmallTextStyle(color: Colors.grey, fontSize: 11),
                            ),
                            Text(
                              name.isNotEmpty ? name : 'Set Name',
                              style: getTitleTextStyle(
                                context,
                                fontSize: 15,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showEditNameDialog(context, name),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                // Dark/Light Theme Mode Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: _cardDecoration(isDarkMode),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                            color: AppColors.primaryColor,
                          ),
                          const Gap(12),
                          Text(
                            "Dark Mode",
                            style: getTitleTextStyle(
                              context,
                              fontSize: 15,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: isDarkMode,
                        activeTrackColor: AppColors.primaryColor,
                        onChanged: (val) {
                          AppLocalStorage.casheData(
                              AppLocalStorage.KIsDarkMode, val);
                        },
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                // App Info & Statistics Card
                ValueListenableBuilder(
                  valueListenable: AppLocalStorage.taskBox.listenable(),
                  builder: (context, Box<TaskModel> taskBox, child) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration(isDarkMode),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primaryColor),
                              const Gap(12),
                              Text(
                                "App Version",
                                style: getTitleTextStyle(
                                  context,
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "v1.0.0 (${taskBox.length} tasks)",
                            style: getSmallTextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Gap(24),
              ],
            ),
          ),
        );
      },
    );
  }
}
