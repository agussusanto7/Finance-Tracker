import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/youtube_video_model.dart';

class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<List<YouTubeVideo>> fetchFinanceVideos() async {
    final apiKey = dotenv.env['YOUTUBE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('YOUTUBE_API_KEY belum di-set di file .env');
    }

    final queryParameters = {
      'part': 'snippet',
      'q': 'cara mengatur keuangan pribadi OR investasi untuk pemula',
      'type': 'video',
      'maxResults': '15',
      'order': 'relevance',
      'key': apiKey,
    };

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['items'];
        return items.map((item) => YouTubeVideo.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil video YouTube: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      throw Exception('Koneksi ke YouTube API gagal: $e');
    }
  }
}
