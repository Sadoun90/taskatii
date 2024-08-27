import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/CustomButton.dart';
import 'package:taskatii/features/home/page/home_view.dart';

class UploadView extends StatefulWidget {
  const UploadView({super.key});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  // XFile ? file;
  String? path;
  String name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                if (path != null && name.isNotEmpty) {
                  AppLocalStorage.casheData(AppLocalStorage.KName, name);
                  AppLocalStorage.casheData(AppLocalStorage.KImage, path);
                  AppLocalStorage.casheData(AppLocalStorage.KIsUpload, true);

                  PushWithReplacement(context, const HomeView());
                } else if (path == null && name.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: AppColors.redcolor,
                      content: const Text('Please upload your Image')));
                } else if (path != null && name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: AppColors.redcolor,
                      content: const Text('Please enter your name')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: AppColors.redcolor,
                      content: const Text(
                          'Please upload your Image and enter your name')));
                }
              },
              child: Text(
                'Done',
                style: getBodyTextStyle(),
              ))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 90,
                  backgroundImage: (path != null)
                      ? FileImage(File(path!))
                      : const NetworkImage(
                          'https://th.bing.com/th/id/OIP.Wim1Ar6paI5-FdmrOedMMAHaHa?w=191&h=191&c=7&r=0&o=5&dpr=1.3&pid=1.7'),
                ),
                const Gap(20),
                CustomButton(
                  text: 'Upload From camera',
                  onPressed: () {
                    pickImage(true);
                  },
                ),
                Gap(20),
                CustomButton(
                  text: 'Upload From Gallery',
                  onPressed: () {
                    pickImage(false);
                  },
                ),
                Gap(20),
                Divider(),
                Gap(20),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: 'Enter Your Name',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: AppColors.PrimaryColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: AppColors.primaryColor)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.redcolor)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.redcolor))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  pickImage(bool iscamera) {
    ImagePicker()
        .pickImage(source: iscamera ? ImageSource.camera : ImageSource.gallery)
        .then((value) {
      if (value != null) {
        setState(() {
          path = value.path;
        });
      }
    });
  }
}
