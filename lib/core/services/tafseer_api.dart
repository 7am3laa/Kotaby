import 'package:dio/dio.dart';
import 'package:kotaby/core/models/tafseer_author.dart';

class ApiServices {
  static const String baseUrl = 'http://api.quran-tafseer.com/';
  static const String tafseerList = 'tafseer';
  final dio = Dio();

  Future<List<TafseerAuthor>> getTafseerList() async {
    try {
      final response = await dio.get('$baseUrl$tafseerList');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => TafseerAuthor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tafseer list');
      }
    } catch (e) {
      print('Error fetching tafseer list: $e');
      return [];
    }
  }

  Future<String> getTafseerText(
      int tafseerId, int surahNumber, int ayahNumber) async {
    try {
      final response =
          await dio.get('$baseUrl/tafseer/$tafseerId/$surahNumber/$ayahNumber');
      if (response.statusCode == 200) {
        return response.data['text'];
      } else {
        throw Exception('Failed to load tafseer text');
      }
    } catch (e) {
      print('Error fetching tafseer text: $e');
      return '';
    }
  }
}
