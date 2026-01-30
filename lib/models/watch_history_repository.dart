import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cine_echo/models/watched_movie.dart';
import 'package:cine_echo/models/watched_episode.dart';
import 'package:cine_echo/models/favorited_series.dart';
import 'package:cine_echo/models/watch_stats.dart';

class WatchHistoryRepository {
  static const String _moviesKey = 'watched_movies';
  static const String _episodesKey = 'watched_episodes';
  static const String _favoritedSeriesKey = 'favorited_series';

  final FlutterSecureStorage _storage;

  WatchHistoryRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  // Mark movie as watched
  Future<void> markMovieWatched(int tmdbId, {bool favorite = false}) async {
    // Validate tmdbId
    if (tmdbId <= 0) {
      throw ArgumentError('Invalid tmdbId: must be greater than 0');
    }

    final movies = await getWatchedMovies();

    final index = movies.indexWhere((m) => m.tmdbId == tmdbId);
    if (index >= 0) {
      movies[index] = WatchedMovie(
        tmdbId: tmdbId,
        watchedAt: movies[index].watchedAt,
        isFavorite: favorite,
      );
    } else {
      movies.add(
        WatchedMovie(
          tmdbId: tmdbId,
          watchedAt: DateTime.now(),
          isFavorite: favorite,
        ),
      );
    }

    await _saveMovies(movies);
  }

  // Unmark movie as watched
  Future<void> unmarkMovieWatched(int tmdbId) async {
    final movies = await getWatchedMovies();
    movies.removeWhere((m) => m.tmdbId == tmdbId);
    await _saveMovies(movies);
  }

  // Mark episode as watched
  Future<void> markEpisodeWatched(
    int seriesTmdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    // Validate all parameters
    if (seriesTmdbId <= 0) {
      throw ArgumentError('Invalid seriesTmdbId: must be greater than 0');
    }
    if (seasonNumber < 0) {
      throw ArgumentError('Invalid seasonNumber: must be >= 0');
    }
    if (episodeNumber <= 0) {
      throw ArgumentError('Invalid episodeNumber: must be greater than 0');
    }

    final episodes = await getWatchedEpisodes();

    final exists = episodes.any(
      (e) =>
          e.seriesTmdbId == seriesTmdbId &&
          e.seasonNumber == seasonNumber &&
          e.episodeNumber == episodeNumber,
    );

    if (!exists) {
      episodes.add(
        WatchedEpisode(
          seriesTmdbId: seriesTmdbId,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          watchedAt: DateTime.now(),
        ),
      );
      await _saveEpisodes(episodes);
    }
  }

  // Unmark episode as watched
  Future<void> unmarkEpisodeWatched(
    int seriesTmdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    final episodes = await getWatchedEpisodes();
    episodes.removeWhere(
      (e) =>
          e.seriesTmdbId == seriesTmdbId &&
          e.seasonNumber == seasonNumber &&
          e.episodeNumber == episodeNumber,
    );
    await _saveEpisodes(episodes);
  }

  // Check if movie is watched
  Future<bool> isMovieWatched(int tmdbId) async {
    final movies = await getWatchedMovies();
    return movies.any((m) => m.tmdbId == tmdbId);
  }

  // Check if episode is watched
  Future<bool> isEpisodeWatched(
    int seriesTmdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    final episodes = await getWatchedEpisodes();
    return episodes.any(
      (e) =>
          e.seriesTmdbId == seriesTmdbId &&
          e.seasonNumber == seasonNumber &&
          e.episodeNumber == episodeNumber,
    );
  }

  // Get all watched movies
  Future<List<WatchedMovie>> getWatchedMovies() async {
    final jsonStr = await _storage.read(key: _moviesKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => WatchedMovie.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Get all watched episodes
  Future<List<WatchedEpisode>> getWatchedEpisodes() async {
    final jsonStr = await _storage.read(key: _episodesKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => WatchedEpisode.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Get watch stats
  Future<WatchStats> getWatchStats() async {
    final movies = await getWatchedMovies();
    final episodes = await getWatchedEpisodes();

    return WatchStats(movies: movies, episodes: episodes);
  }

  // Clear all watch history
  Future<void> clearWatchHistory() async {
    await _storage.delete(key: _moviesKey);
    await _storage.delete(key: _episodesKey);
    await _storage.delete(key: _favoritedSeriesKey);
  }

  // Mark series as favorite
  Future<void> markSeriesFavorite(int seriesTmdbId) async {
    // Validate seriesTmdbId
    if (seriesTmdbId <= 0) {
      throw ArgumentError('Invalid seriesTmdbId: must be greater than 0');
    }

    final favoritedSeries = await getFavoritedSeries();

    final exists = favoritedSeries.any((s) => s.seriesTmdbId == seriesTmdbId);
    if (!exists) {
      favoritedSeries.add(
        FavoritedSeries(
          seriesTmdbId: seriesTmdbId,
          favoritedAt: DateTime.now(),
        ),
      );
      await _saveFavoritedSeries(favoritedSeries);
    }
  }

  // Unmark series from favorite
  Future<void> unmarkSeriesFavorite(int seriesTmdbId) async {
    final favoritedSeries = await getFavoritedSeries();
    favoritedSeries.removeWhere((s) => s.seriesTmdbId == seriesTmdbId);
    await _saveFavoritedSeries(favoritedSeries);
  }

  // Check if series is favorited
  Future<bool> isSeriesFavorited(int seriesTmdbId) async {
    final favoritedSeries = await getFavoritedSeries();
    return favoritedSeries.any((s) => s.seriesTmdbId == seriesTmdbId);
  }

  // Get all favorited series
  Future<List<FavoritedSeries>> getFavoritedSeries() async {
    final jsonStr = await _storage.read(key: _favoritedSeriesKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => FavoritedSeries.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveFavoritedSeries(List<FavoritedSeries> series) async {
    final jsonStr = jsonEncode(series.map((s) => s.toJson()).toList());
    await _storage.write(key: _favoritedSeriesKey, value: jsonStr);
  }

  Future<void> _saveMovies(List<WatchedMovie> movies) async {
    final jsonStr = jsonEncode(movies.map((m) => m.toJson()).toList());
    await _storage.write(key: _moviesKey, value: jsonStr);
  }

  Future<void> _saveEpisodes(List<WatchedEpisode> episodes) async {
    final jsonStr = jsonEncode(episodes.map((e) => e.toJson()).toList());
    await _storage.write(key: _episodesKey, value: jsonStr);
  }
}
