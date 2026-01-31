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
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      return {
        'results': data['results'] as List<dynamic>? ?? [],
        'total_pages': (data['total_pages'] as int?) ?? 1,
      };
    } catch (e) {
      throw Exception('Error fetching section data: $e');
    }
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

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch genre data: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      return {
        'results': data['results'] as List<dynamic>? ?? [],
        'total_pages': (data['total_pages'] as int?) ?? 1,
        'current_page': page,
      };
    } catch (e) {
      throw Exception('Error fetching genre data: $e');
    }
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

  Future<Map<String, dynamic>> fetchDetails(
    String id,
    String type, {
    required bool isSeason,
  }) async {
    final url =
        'https://api.themoviedb.org/3/${type.trim()}/${id.trim()}'
        '?api_key=${Env.tmdbApiKey}'
        '&append_to_response=videos,credits,recommendations'
        '&language=en-US';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch details: ${response.statusCode}');
      }

      return json.decode(response.body) as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Error fetching details: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCastDetails(String id) async {
    final url =
        'https://api.themoviedb.org/3/person/$id'
        '?api_key=${Env.tmdbApiKey}'
        '&append_to_response=movie_credits';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch cast details: ${response.statusCode}');
      }

      return json.decode(response.body) as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Error fetching cast details: $e');
    }
  }

  Future<Map<String, dynamic>> searchMulti(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      return {'results': [], 'total_pages': 0, 'total_results': 0};
    }

    final url =
        'https://api.themoviedb.org/3/search/multi'
        '?api_key=${Env.tmdbApiKey}'
        '&query=${Uri.encodeComponent(query)}'
        '&page=$page'
        '&language=en-US';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Search failed: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      return {
        'results': data['results'] as List<dynamic>? ?? [],
        'total_pages': (data['total_pages'] as int?) ?? 0,
        'total_results': (data['total_results'] as int?) ?? 0,
      };
    } catch (e) {
      throw Exception('Error searching: $e');
    }
  }

  Future<Map<String, dynamic>> fetchSeasonDetails(
    String tvId,
    int seasonNumber,
  ) async {
    final url =
        'https://api.themoviedb.org/3/tv/$tvId/season/$seasonNumber'
        '?api_key=${Env.tmdbApiKey}'
        '&language=en-US';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch season details: ${response.statusCode}',
        );
      }

      return json.decode(response.body) as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Error fetching season details: $e');
    }
  }
}
