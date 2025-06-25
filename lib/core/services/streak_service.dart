import 'package:dio/dio.dart';
import 'package:kotaby/core/models/streak_model.dart';
import 'package:kotaby/storage.dart';

class StreakService {
  final Dio dio = Dio();
  static const String _baseUrl = 'https://kotaby.duckdns.org/streak/';
  Future<void> updateStreak({
    required int lastSurah,
    required int lastAyah,
  }) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        '${_baseUrl}update/${Storage.useridCached}',
        data: {
          "date": DateTime.now().toIso8601String(),
          "lastSurah": lastSurah,
          "lastAyah": lastAyah
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("✅ Streak updated: ${response.data}");
    } on DioException catch (e) {
      print("❌ Server Error (500): ${e.response?.data}");

      rethrow;
    }
  }

  Future<StreakModel> getStreak() async {
    try {
      final response = await dio.get('$_baseUrl${Storage.useridCached}');
      print(response.data);
      return StreakModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<int?> getUserProgressMemorize() async {
    try {
      final response = await dio.get(
        'https://kotaby.duckdns.org/quran/progress/${Storage.useridCached}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      int progress = int.tryParse(response.data.toString()) ?? 0;
      return progress;
    } catch (e) {
      print('Error fetching user progress: $e');
      return null;
    }
  }
}
