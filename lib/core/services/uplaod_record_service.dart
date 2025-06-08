import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kotaby/core/models/upload_record_model.dart';

class UplaodRecordService {
  final Dio _dio = Dio();
  final String _url = 'https://test6-0b77677-v1.app.beam.cloud';
  final String _token =
      'MH9eOBlNHZkV8U8iuOj8mEE1WGdPbHKowFnG3TsG0aAmAqQTs6IeIFlB-GjN9JEz9l7OHaCTqI77Lsb5c3BlYw==';

  Future<UploadRecordModel> uploadAudio(String filePath) async {
    try {
      final fileBytes = await File(filePath).readAsBytes();
      final base64Audio = base64Encode(fileBytes);

      final response = await _dio.post(
        _url,
        data: {
          "audio_data": base64Audio,
          "filename": "audio.wav",
          "content_type": "audio/wav",
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $_token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        print(response.data['transcription']);
        return UploadRecordModel.fromJson(response.data);
      } else {
        throw Exception('Invalid server response');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}
