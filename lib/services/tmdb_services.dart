import 'package:cine_echo/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TmdbServices {
  Future<List<dynamic>> fetchSectionData(String endpoint) async {
    final url =
        'https://api.themoviedb.org/3$endpoint?api_key=${Env.tmdbApiKey}';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    return data['results'];
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
