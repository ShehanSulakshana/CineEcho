import 'package:cine_echo/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TmdbServices {
  Future<Map<String, dynamic>> fetchSectionData(
    String endpoint, {
    int page = 1,
  }) async {
    final url =
        'https://api.themoviedb.org/3$endpoint?api_key=${Env.tmdbApiKey}&page=$page';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    return {
      'results': data['results'] as List<dynamic>,
      'total_pages': data['total_pages'] as int,
    };
  }

  Future<Map<String, dynamic>> fetchGenreDataPaginated(
    String mediaType,
    int genreId, {
    int page = 1,
  }) async {
    final endpoint = mediaType == 'movie' ? '/discover/movie' : '/discover/tv';
    final url =
        'https://api.themoviedb.org/3$endpoint?api_key=${Env.tmdbApiKey}'
        '&with_genres=$genreId'
        '&language=en-US'
        '&page=$page';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    return {
      'results': data['results'] as List<dynamic>,
      'total_pages': data['total_pages'] as int,
      'current_page': page,
    };
  }

  Future<List<dynamic>> fetchGenreData(String mediaType, int genreId) async {
    final endpoint = mediaType == 'movie' ? '/discover/movie' : '/discover/tv';
    final url =
        'https://api.themoviedb.org/3$endpoint?api_key=${Env.tmdbApiKey}'
        '&with_genres=$genreId'
        '&language=en-US'
        '&page=1';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    return data['results'];
  }
}
