import 'package:flutter/foundation.dart';
import 'package:cine_echo/services/tmdb_services.dart';

class TmdbProvider extends ChangeNotifier {
  final TmdbServices _tmdbServices = TmdbServices();

  List<dynamic> _trending = [];
  List<dynamic> _popularMovie = [];
  List<dynamic> _popularTv = [];
  List<dynamic> _topRatedMovie = [];
  List<dynamic> _topRatedTv = [];
  List<dynamic> _upcomingMovies = [];

  int _popularMovieTotalPages = 1;
  int _popularTvTotalPages = 1;
  int _topRatedMovieTotalPages = 1;
  int _topRatedTvTotalPages = 1;
  int _upcomingMoviesTotalPages = 1;

  bool _isDiscoverLoading = true;

  final Map<String, List<dynamic>> _genreData = {};
  final Map<String, int> _genreCurrentPage = {};
  final Map<String, int> _genreTotalPages = {};
  final Map<String, bool> _genreLoading = {};
  final Map<String, bool> _genreLoadingMore = {};
  List<dynamic> get trending => _trending;
  List<dynamic> get popularMovie => _popularMovie;
  List<dynamic> get popularTv => _popularTv;
  List<dynamic> get topRatedMovie => _topRatedMovie;
  List<dynamic> get topRatedTv => _topRatedTv;
  List<dynamic> get upcomingMovies => _upcomingMovies;

  int get popularMovieTotalPages => _popularMovieTotalPages;
  int get popularTvTotalPages => _popularTvTotalPages;
  int get topRatedMovieTotalPages => _topRatedMovieTotalPages;
  int get topRatedTvTotalPages => _topRatedTvTotalPages;
  int get upcomingMoviesTotalPages => _upcomingMoviesTotalPages;

  bool get isDiscoverLoading => _isDiscoverLoading;

  List<dynamic> getGenreData(String key) => _genreData[key] ?? [];
  int getGenreCurrentPage(String key) => _genreCurrentPage[key] ?? 1;
  int getGenreTotalPages(String key) => _genreTotalPages[key] ?? 1;
  bool isGenreLoading(String key) => _genreLoading[key] ?? true;
  bool isGenreLoadingMore(String key) => _genreLoadingMore[key] ?? false;

  Future<void> loadDiscoverData() async {
    if (!_isDiscoverLoading) {
      _isDiscoverLoading = true;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _tmdbServices
            .fetchSectionData('/trending/all/day')
            .catchError((_) => {'results': [], 'total_pages': 1}),
        _tmdbServices
            .fetchSectionData('/movie/popular')
            .catchError((_) => {'results': [], 'total_pages': 1}),
        _tmdbServices
            .fetchSectionData('/tv/popular')
            .catchError((_) => {'results': [], 'total_pages': 1}),
        _tmdbServices
            .fetchSectionData('/movie/top_rated')
            .catchError((_) => {'results': [], 'total_pages': 1}),
        _tmdbServices
            .fetchSectionData('/tv/top_rated')
            .catchError((_) => {'results': [], 'total_pages': 1}),
        _tmdbServices
            .fetchSectionData('/movie/upcoming')
            .catchError((_) => {'results': [], 'total_pages': 1}),
      ]);

      _trending = results[0]['results'] ?? [];
      _popularMovie = results[1]['results'] ?? [];
      _popularMovieTotalPages = results[1]['total_pages'] ?? 1;
      _popularTv = results[2]['results'] ?? [];
      _popularTvTotalPages = results[2]['total_pages'] ?? 1;
      _topRatedMovie = results[3]['results'] ?? [];
      _topRatedMovieTotalPages = results[3]['total_pages'] ?? 1;
      _topRatedTv = results[4]['results'] ?? [];
      _topRatedTvTotalPages = results[4]['total_pages'] ?? 1;
      _upcomingMovies = results[5]['results'] ?? [];
      _upcomingMoviesTotalPages = results[5]['total_pages'] ?? 1;

      bool hasAnyData =
          _trending.isNotEmpty ||
          _popularMovie.isNotEmpty ||
          _popularTv.isNotEmpty ||
          _topRatedMovie.isNotEmpty ||
          _topRatedTv.isNotEmpty ||
          _upcomingMovies.isNotEmpty;

      if (!hasAnyData) {
        throw Exception(
          'Failed to load discover data. Please check your connection.',
        );
      }

      _isDiscoverLoading = false;
      notifyListeners();
    } catch (e) {
      _isDiscoverLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadGenreData(
    String mediaType,
    int genreId, {
    bool loadMore = false,
  }) async {
    final key = '${mediaType}_$genreId';

    if (!loadMore) {
      _genreLoading[key] = true;
      _genreCurrentPage[key] = 1;
    } else {
      _genreLoadingMore[key] = true;
      _genreCurrentPage[key] = (_genreCurrentPage[key] ?? 1) + 1;
    }
    notifyListeners();

    try {
      final currentPage = _genreCurrentPage[key] ?? 1;
      final data = await _tmdbServices.fetchGenreDataPaginated(
        mediaType,
        genreId,
        page: currentPage,
      );

      if (loadMore) {
        _genreData[key] = [...(_genreData[key] ?? []), ...data['results']];
      } else {
        _genreData[key] = data['results'];
      }

      _genreTotalPages[key] = data['total_pages'];
      _genreLoading[key] = false;
      _genreLoadingMore[key] = false;
      notifyListeners();
    } catch (e) {
      _genreLoading[key] = false;
      _genreLoadingMore[key] = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMoreGenreData(String mediaType, int genreId) async {
    final key = '${mediaType}_$genreId';
    final currentPage = _genreCurrentPage[key] ?? 1;
    final totalPages = _genreTotalPages[key] ?? 1;

    if (currentPage < totalPages && !(_genreLoadingMore[key] ?? false)) {
      _genreCurrentPage[key] = currentPage + 1;
      await loadGenreData(mediaType, genreId, loadMore: true);
    }
  }

  Future<Map<String, dynamic>> fetchSectionData(
    String endpoint, {
    int page = 1,
  }) async {
    return await _tmdbServices.fetchSectionData(endpoint, page: page);
  }

  Future<Map<String, dynamic>> fetchDetails(
    String id,
    String type, {
    bool isSeason = false,
  }) async {
    return await _tmdbServices.fetchDetails(id, type, isSeason: isSeason);
  }

  Future<Map<String, dynamic>> fetchCastDetails(String id) async {
    return await _tmdbServices.fetchCastDetails(id);
  }

  void resetGenreData(String key) {
    _genreData[key] = [];
    _genreCurrentPage[key] = 1;
    _genreTotalPages[key] = 1;
    _genreLoading[key] = true;
    _genreLoadingMore[key] = false;
    notifyListeners();
  }
}
