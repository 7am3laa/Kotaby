class TaskSummary {
  final int totalTasks;
  final int completedTasks;
  final int remainingTasks;
  final int totalPages;
  final double completionPercentage;

  TaskSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.remainingTasks,
    required this.totalPages,
    required this.completionPercentage,
  });

  factory TaskSummary.fromJson(Map<String, dynamic> json) {
    return TaskSummary(
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      remainingTasks: json['remainingTasks'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      completionPercentage: json['completionPercentage'] ?? 0,
    );
  }
}
