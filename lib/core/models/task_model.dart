class TaskModel {
  final int id;
  final int userId;
  final int dayNumber;
  final int startPage;
  final int endPage;
  final DateTime taskDate;
  final int progress;
  final String surahRange;
  final bool completed;

  TaskModel({
    required this.id,
    required this.userId,
    required this.dayNumber,
    required this.startPage,
    required this.endPage,
    required this.taskDate,
    required this.progress,
    required this.surahRange,
    required this.completed,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      dayNumber: json['dayNumber'] ?? 0,
      startPage: json['startPage'] ?? 0,
      endPage: json['endPage'] ?? 0,
      taskDate: DateTime.parse(json['taskDate']),
      progress: json['progress'] ?? 0,
      surahRange: json['surahRange'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dayNumber': dayNumber,
      'startPage': startPage,
      'endPage': endPage,
      'taskDate': taskDate.toIso8601String(),
      'progress': progress,
      'surahRange': surahRange,
      'completed': completed,
    };
  }
}
