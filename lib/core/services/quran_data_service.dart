import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kotaby/core/models/users_model.dart';

class QuranDataService {
  final Dio dio = Dio();
  static const _baseUrl = "https://kotaby.duckdns.org/";

  Future<List<dynamic>?> getPage({
    required String pageNumber,
  }) async {
    try {
      final response = await dio.get(
        '${_baseUrl}quran/page/$pageNumber',
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e, "Registration");
      return null;
    }
  }

  List<dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    }
    throw Exception("Request failed: ${response.statusCode}");
  }

  void _handleDioError(DioException e, String operation) {
    final errorMessage =
        e.response?.data?['message'] ?? e.message ?? 'Unknown $operation error';
    print("$operation Error: $errorMessage");
  }
}
