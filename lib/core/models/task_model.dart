import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String discription;

  @HiveField(3)
  String date;

  @HiveField(4)
  String startTime;

  @HiveField(5)
  String endTime;

  @HiveField(6)
  int color;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  String? category;

  @HiveField(9)
  int? priority;

  @HiveField(10)
  List<String>? subTasks;

  @HiveField(11)
  List<bool>? subTasksCompleted;

  @HiveField(12)
  String? isRepeat; // 'None', 'Daily', 'Weekly', 'Monthly'

  @HiveField(13)
  int? notificationId;

  TaskModel({
    required this.id,
    required this.title,
    required this.discription,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.isCompleted,
    this.category,
    this.priority,
    this.subTasks,
    this.subTasksCompleted,
    this.isRepeat = 'None',
    this.notificationId,
  });

  String get description => discription;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'discription': discription,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'color': color,
      'is_completed': isCompleted,
      'category': category,
      'priority': priority,
      'sub_tasks': subTasks,
      'sub_tasks_completed': subTasksCompleted,
      'is_repeat': isRepeat,
      'notification_id': notificationId,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      discription: json['discription'] as String? ?? '',
      date: json['date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      color: json['color'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      category: json['category'] as String?,
      priority: json['priority'] as int?,
      subTasks: (json['sub_tasks'] as List?)?.cast<String>(),
      subTasksCompleted: (json['sub_tasks_completed'] as List?)?.cast<bool>(),
      isRepeat: json['is_repeat'] as String? ?? 'None',
      notificationId: json['notification_id'] as int?,
    );
  }
}
