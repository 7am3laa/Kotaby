import 'package:dio/dio.dart';
import 'package:kotaby/core/models/task_model.dart';
import 'package:kotaby/core/models/task_summary.dart';
import 'package:kotaby/storage.dart';

class TasksService {
  final Dio dio = Dio();
  static const _baseUrl = "https://kotaby.duckdns.org/tasks/";

  Future<List<TaskModel>> createTasks({
    required int days,
  }) async {
    try {
      final response = await dio.post(
        '${_baseUrl}create-reading-plan',
        queryParameters: {
          'userId': Storage.useridCached,
          'days': days,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<List<TaskModel>> getUserTasks() async {
    try {
      final response = await dio.get(
        '${_baseUrl}user/${Storage.useridCached}',
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<TaskModel> completeTask(int taskId) async {
    try {
      final response = await dio.put(
        '$_baseUrl$taskId/complete',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<TaskSummary> getTaskSummary() async {
    try {
      final response = await dio.get(
        '${_baseUrl}user/${Storage.useridCached}/summary',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      print(response.data);
      return TaskSummary.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> deleteUserTasks() async {
    try {
      final response = await dio.delete(
        '${_baseUrl}user/${Storage.useridCached}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Tasks for user ${Storage.useridCached} deleted successfully.');
      } else {
        print('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }
}
