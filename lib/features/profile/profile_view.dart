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

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // XFile ? file;
  String? path;
  String name = '';

  @override
  void initState() {
    path = AppLocalStorage.getCachedData(AppLocalStorage.KImage);
    name = AppLocalStorage.getCachedData(AppLocalStorage.KName);
    super.initState();
  }

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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 90,
                      backgroundImage: (path != null)
                          ? FileImage(File(path!))
                          : const NetworkImage(
                              'https://th.bing.com/th/id/OIP.Wim1Ar6paI5-FdmrOedMMAHaHa?w=191&h=191&c=7&r=0&o=5&dpr=1.3&pid=1.7'),
                    ),
                    Positioned(
                        bottom: 10,
                        right: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  backgroundColor: AppColors.whiteColor,
                                  builder: (contex) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Container(
                                        width: double.infinity,
                                        height: 170,
                                        decoration: BoxDecoration(
                                            color: AppColors.whiteColor,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomButton(
                                              width: double.infinity,
                                              onPressed: () {
                                                pickImage(true);
                                                Navigator.pop(context);
                                              },
                                              text: 'Upload from Camera',
                                            ),
                                            Gap(10),
                                            CustomButton(
                                              width: double.infinity,
                                              onPressed: () {
                                                pickImage(false);
                                                Navigator.pop(context);
                                              },
                                              text: 'Upload from Gallery',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.blackColor,
                                )),
                          ),
                        ))
                  ],
                ),
                const Gap(20),
                Gap(20),
                Divider(
                  color: AppColors.PrimaryColor,
                ),
                Gap(20),
                Row(
                  children: [
                    Text(
                      name,
                      style: getTitleTextStyle(),
                    ),
                    Spacer(),
                    IconButton.outlined(
                        onPressed: () {},
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.PrimaryColor,
                        ))
                  ],
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
        AppLocalStorage.casheData(AppLocalStorage.KImage, path);
      }
    });
  }
}
