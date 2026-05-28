import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeService {
  static const String apiKey = 'API_KEY';

  static Future<List<dynamic>> fetchVideos() async {
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=tamil+new+songs&type=video&maxResults=10&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body)['items'];
    } else {
      throw Exception('Failed to load videos');
    }
  }

  static Future<List<dynamic>> searchVideos(String query) async {
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&maxResults=10&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body)['items'];
    } else {
      throw Exception('Search failed');
    }
  }
}
