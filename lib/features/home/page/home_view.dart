import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/features/auth/login_view.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/widgets/task_item.dart';
import 'package:taskatii/features/add_task/add_task.dart';
import 'package:taskatii/features/home/widgets/home_header_widget.dart';
import 'package:taskatii/features/home/widgets/task_details_sheet.dart';
import 'package:taskatii/features/home/widgets/task_progress_widget.dart';
import 'package:taskatii/features/home/widgets/today_header.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String selectDate = DateFormat.yMd().format(DateTime.now());
  String searchQuery = '';
  String selectedCategoryFilter = 'All';

  final List<String> filterCategories = [
    'All',
    'General',
    'Work',
    'Personal',
    'Study',
    'Health',
    'Shopping',
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          if (AppLocalStorage.isGuest) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign In Required 🔐'),
                content: const Text(
                  'You are currently in Guest Mode. Please sign in to add and manage your tasks.',
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
                      Navigator.pop(context);
                      Push(context, const LoginView());
                    },
                    child: const Text('Sign In', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
            return;
          }
          Push(context, const AddTask());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeaderWidget(),
                const Gap(8),
                const TodayHeader(),
                const Gap(8),

                // Search Bar with Clear Icon & Subtask Search
                TextField(
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search title, notes or sub-tasks...',
                    prefixIcon:
                        Icon(Icons.search, color: AppColors.primaryColor),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const Gap(8),

                // Date Picker bounded inside SizedBox
                SizedBox(
                  height: 90,
                  child: DatePicker(
                    DateTime.now().subtract(const Duration(days: 3)),
                    height: 90,
                    width: 66,
                    initialSelectedDate: DateTime.now(),
                    selectionColor: AppColors.primaryColor,
                    dateTextStyle: getBodyTextStyle(context, fontSize: 15),
                    monthTextStyle: getBodyTextStyle(context, fontSize: 11),
                    dayTextStyle: getBodyTextStyle(context, fontSize: 11),
                    selectedTextColor: Colors.white,
                    onDateChange: (date) {
                      setState(() {
                        selectDate = DateFormat.yMd().format(date);
                      });
                    },
                  ),
                ),
                const Gap(8),

                // Category Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterCategories.length,
                    itemBuilder: (context, index) {
                      final cat = filterCategories[index];
                      bool isSelected = selectedCategoryFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedCategoryFilter = cat;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Gap(12),

                // Task List + Progress Tracker
                ValueListenableBuilder(
                  valueListenable: AppLocalStorage.taskBox.listenable(),
                  builder: (context, Box<TaskModel> taskBox, child) {
                    List<TaskModel> dayTasks = taskBox.values
                        .where((task) => task.date == selectDate)
                        .toList();

                    List<TaskModel> filteredTasks = dayTasks.where((task) {
                      bool matchesSearch = searchQuery.isEmpty ||
                          task.title.toLowerCase().contains(searchQuery) ||
                          task.discription.toLowerCase().contains(searchQuery) ||
                          (task.subTasks != null &&
                              task.subTasks!.any((st) =>
                                  st.toLowerCase().contains(searchQuery)));

                      bool matchesCategory = selectedCategoryFilter == 'All' ||
                          (task.category?.toLowerCase() ==
                              selectedCategoryFilter.toLowerCase());

                      return matchesSearch && matchesCategory;
                    }).toList();

                    return Column(
                      children: [
                        if (dayTasks.isNotEmpty) ...[
                          TaskProgressWidget(tasks: dayTasks),
                          const Gap(12),
                        ],
                        filteredTasks.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        'assets/empty.json',
                                        height: 150,
                                      ),
                                      const Gap(10),
                                      Text(
                                        'No Tasks Found',
                                        style: getBodyTextStyle(context,
                                            color: AppColors.primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  return TaskItemWidget(
                                    model: task,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            TaskDetailsSheet(task: task),
                                      );
                                    },
                                  );
                                },
                              ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
