import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/hadith_model.dart';

class HadithApiService {
  static const String baseUrl = 'http://kotaby.duckdns.org/hadith/search';

  static Future<HadithResponse> searchHadith(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = '$baseUrl?q=$encodedQuery';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print((jsonData['data'] as List).length);
        final ahadiths = <HadithResult>[];
        for (var hadith in jsonData['data']) {
          if (hadith['hadithText'] == null) {
            continue;
          }
          ahadiths.add(HadithResult(
            hadithText: hadith['hadithText'],
            narrator: hadith['narrator'],
            scholar: hadith['scholar'],
            source: hadith['source'],
            authenticity: hadith['authenticity'],
          ));
        }
        return HadithResponse(
          ahadith: ahadiths,
        );
      } else {
        throw Exception('Failed to load hadith: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching hadith: $e');
    }
  }

  Future<void> testApiEndpoint({
    required String url,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      http.Response response;

      // Choose HTTP method
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: headers);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: headers);
          break;
        default:
          throw 'Unsupported HTTP method: $method';
      }

      // Log the response
      print('--- API Response ---');
      print('URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      // Handle errors
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Success!');
      } else {
        print('❌ Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('🔥 Exception: $e');
    }
  }

  Future<bool> testAudioUpload({required String filePath}) async {
    try {
      var request = http.MultipartRequest('POST',
          Uri.parse("http://kotaby.duckdns.org/memo/transcribe?id=1&page=1"))
        ..headers.addAll({
          'accept': 'application/json',
        })
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: $responseBody');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }
}
