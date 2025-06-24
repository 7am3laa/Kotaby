import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kotaby/core/models/users_model.dart';

class UserAuthServices {
  final Dio dio = Dio();
  static const _baseUrl = "https://kotaby.duckdns.org/";

  Future<Map<String, dynamic>?> register({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${_baseUrl}users/register',
        data: {
          "userName": userName,
          "email": email,
          "password": password,
          "dateOfBirth": DateTime.now().toIso8601String(),
          "nationality": "Egypt",
          "image": "",
        },
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

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${_baseUrl}users/login',
        data: {"email": email, "password": password},
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e, "Login");
      return null;
    }
  }

  Future<Map<String, dynamic>?> update({
    required int userId,
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${_baseUrl}users/$userId/update',
        data: {
          "id": userId,
          "userName": userName,
          "password": password,
          "email": email,
        },
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e, "Update");
      return null;
    }
  }

  Future<List<UsersModel>> getUsers() async {
    try {
      final response = await dio.get(
        '${_baseUrl}users',
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((userJson) => UsersModel.fromJson(userJson)).toList();
      }

      throw Exception("Failed with status: ${response.statusCode}");
    } on DioException catch (e) {
      _handleDioError(e, "Fetch Users");
      rethrow;
    }
  }

  Future<void> forgetPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${_baseUrl}users/reset-password',
        data: {
          "email": email,
          "password": password,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print(response.data);
        return response.data;
      } else {
        throw Exception("Reset failed: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      _handleDioError(e, "Reset Password");
      return;
    }
  }

  Future<void> putProfilePic({
    required int userId,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await dio.post(
        '${_baseUrl}users/$userId/photo',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      _handleDioError(e, "Profile Picture Update");
      rethrow;
    }
  }

  Future<UsersModel> getUserById({required int userId}) async {
    try {
      final response = await dio.get('${_baseUrl}users/$userId');

      if (response.statusCode == 200) {
        return UsersModel.fromJson(_handleResponse(response));
      } else {
        throw Exception("فشل في جلب البيانات: ${response.statusCode}");
      }
    } on DioException catch (e) {
      _handleDioError(e, "Get User");
      rethrow;
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع: $e");
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    }
    throw Exception("Request failed: ${response.statusCode}");
  }

  void _handleDioError(DioException e, String operation) {
    final errorMessage =
        e.response?.data?['message'] ?? e.message ?? 'Unknown $operation error';
    if (errorMessage == "The connection errored") {
      print("$operation Error: $errorMessage");
    }
  }
}
