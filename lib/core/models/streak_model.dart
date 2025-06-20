class StreakModel {
  final int id;
  final int userId;
  final String lastRead;
  final int currentStreak;
  final int maxStreak;

  StreakModel({
    required this.id,
    required this.userId,
    required this.lastRead,
    required this.currentStreak,
    required this.maxStreak,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      id: json['id'],
      userId: json['userId'],
      lastRead: json['lastRead'],
      currentStreak: json['currentStreak'],
      maxStreak: json['maxStreak'],
    );
  }
}
