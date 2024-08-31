import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/CustomButton.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? path;
  String name = '';

  @override
  void initState() {
    path = AppLocalStorage.getCachedData(AppLocalStorage.KImage);
    name = AppLocalStorage.getCachedData(AppLocalStorage.KName) ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool mode =
        AppLocalStorage.getCachedData(AppLocalStorage.KIsDarkMode) ?? false;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryColor,
          ),
        ),
        actions: [
          // make dark and light button
          IconButton(
              onPressed: () {
                AppLocalStorage.casheData(AppLocalStorage.KIsDarkMode, !mode);
                setState(() {});
              },
              icon: Icon(
                mode ? Icons.light_mode  : Icons.dark_mode,
                color: AppColors.PrimaryColor,
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
                      backgroundImage: path != null
                          ? FileImage(File(path!))
                          : const NetworkImage(
                                  'https://th.bing.com/th/id/OIP.Wim1Ar6paI5-FdmrOedMMAHaHa?w=191&h=191&c=7&r=0&o=5&dpr=1.3&pid=1.7')
                              as ImageProvider,
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
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Container(
                                    width: double.infinity,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      color: AppColors.darkColorScaffoldColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
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
                                        const Gap(10),
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
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const Gap(20),
                Divider(color: AppColors.primaryColor),
                const Gap(20),
                Row(
                  children: [
                    Text(
                      name,
                      style: getTitleTextStyle(context,
                          color: AppColors.primaryColor),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String newName = name;
                            return AlertDialog(
                              title: Text(
                                'Edit Name',
                                style: TextStyle(color: AppColors.blackColor),
                              ),
                              content: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    newName = value;
                                  });
                                },
                                controller: TextEditingController(text: name),
                                decoration: InputDecoration(
                                  hintText: "Enter your name",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Save'),
                                  onPressed: () {
                                    setState(() {
                                      name = newName;
                                      AppLocalStorage.casheData(
                                          AppLocalStorage.KName, name);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pickImage(bool isCamera) async {
    final pickedFile = await ImagePicker().pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        path = pickedFile.path;
        AppLocalStorage.casheData(AppLocalStorage.KImage, path);
      });
    }
  }
}
