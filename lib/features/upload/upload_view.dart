import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/widgets/CustomButton.dart';
import 'package:taskatii/core/widgets/user_avatar.dart';
import 'package:taskatii/features/main_layout/main_layout.dart';

class UploadView extends StatefulWidget {
  const UploadView({super.key});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  String? path;
  String name = '';

  void pickImage(bool isCamera) async {
    final value = await ImagePicker().pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (value != null) {
      setState(() {
        path = value.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              if (path != null && name.trim().isNotEmpty) {
                AppLocalStorage.casheData(AppLocalStorage.KName, name.trim());
                AppLocalStorage.casheData(AppLocalStorage.KImage, path);
                AppLocalStorage.casheData(AppLocalStorage.KIsUpload, true);
                PushWithReplacement(context, const MainLayout());
              } else if (path == null && name.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: AppColors.redcolor,
                  content: const Text('Please upload your Image'),
                ));
              } else if (path != null && name.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: AppColors.redcolor,
                  content: const Text('Please enter your name'),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: AppColors.redcolor,
                  content: const Text(
                    'Please upload your Image and enter your name',
                  ),
                ));
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UserAvatar(
                  imagePath: path,
                  radius: 75,
                ),
                const Gap(24),
                CustomButton(
                  text: 'Upload From Camera',
                  onPressed: () {
                    pickImage(true);
                  },
                ),
                const Gap(12),
                CustomButton(
                  text: 'Upload From Gallery',
                  onPressed: () {
                    pickImage(false);
                  },
                ),
                const Gap(24),
                const Divider(),
                const Gap(24),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Your Name',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
