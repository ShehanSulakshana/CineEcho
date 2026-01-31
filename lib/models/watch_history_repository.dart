import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cine_echo/models/favorited_movie.dart';
import 'package:cine_echo/models/favorited_series.dart';
import 'package:cine_echo/models/watched_episode.dart';
import 'package:cine_echo/models/watched_movie.dart';
import 'package:cine_echo/models/watch_stats.dart';

class WatchHistoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const int _batchSizeLimit = 400;

  WatchHistoryRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _watchedMoviesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('watched_movies');

  CollectionReference<Map<String, dynamic>> _watchedEpisodesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('watched_episodes');

  CollectionReference<Map<String, dynamic>> _favoriteMoviesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorite_movies');

  CollectionReference<Map<String, dynamic>> _favoriteSeriesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorite_series');

  DocumentReference<Map<String, dynamic>> _statsDocRef(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .collection('stats')
      .doc('summary');

  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Iterable<List<T>> _chunk<T>(List<T> items, int chunkSize) sync* {
    for (var i = 0; i < items.length; i += chunkSize) {
      final end = (i + chunkSize < items.length) ? i + chunkSize : items.length;
      yield items.sublist(i, end);
    }
  }

  Future<void> markMovieWatched(int tmdbId, {bool favorite = false}) async {
    if (tmdbId <= 0) {
      throw ArgumentError('Invalid tmdbId: must be greater than 0');
    }
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      await _watchedMoviesRef(uid).doc(tmdbId.toString()).set({
        'tmdbId': tmdbId,
        'watchedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (favorite) {
        await markMovieFavorite(tmdbId);
      }

      await _updateStats(uid);
    } catch (e) {
      throw Exception('Failed to mark movie as watched: $e');
    }
  }

  Future<void> unmarkMovieWatched(int tmdbId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    try {
      await _watchedMoviesRef(uid).doc(tmdbId.toString()).delete();
      await _updateStats(uid);
    } catch (e) {
      throw Exception('Failed to unmark movie: $e');
    }
  }

  Future<void> markEpisodeWatched(
    int seriesTmdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    if (seriesTmdbId <= 0) {
      throw ArgumentError('Invalid seriesTmdbId: must be greater than 0');
    }
    if (seasonNumber < 0) {
      throw ArgumentError('Invalid seasonNumber: must be >= 0');
    }
    if (episodeNumber <= 0) {
      throw ArgumentError('Invalid episodeNumber: must be greater than 0');
    }

    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final episodeKey =
          '${seriesTmdbId}_S$seasonNumber'
          'E$episodeNumber';
      await _watchedEpisodesRef(uid).doc(episodeKey).set({
        'seriesTmdbId': seriesTmdbId,
        'seasonNumber': seasonNumber,
        'episodeNumber': episodeNumber,
        'watchedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _updateStats(uid);
    } catch (e) {
      throw Exception('Failed to mark episode as watched: $e');
    }
  }

  Future<void> unmarkEpisodeWatched(
    int seriesTmdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    try {
      final episodeKey =
          '${seriesTmdbId}_S$seasonNumber'
          'E$episodeNumber';
      await _watchedEpisodesRef(uid).doc(episodeKey).delete();
      await _updateStats(uid);
    } catch (e) {
      throw Exception('Failed to unmark episode: $e');
    }
  }

  Future<void> markEpisodesWatchedBatch(
    int seriesTmdbId,
    List<Map<String, int>> episodes,
  ) async {
    if (seriesTmdbId <= 0) {
      throw ArgumentError('Invalid seriesTmdbId: must be greater than 0');
    }
    if (episodes.isEmpty) return;

    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      for (final chunk in _chunk(episodes, _batchSizeLimit)) {
        final batch = _firestore.batch();
        for (final episode in chunk) {
          final seasonNumber = episode['seasonNumber'] ?? -1;
          final episodeNumber = episode['episodeNumber'] ?? -1;
          if (seasonNumber < 0 || episodeNumber <= 0) continue;

          final episodeKey =
              '${seriesTmdbId}_S$seasonNumber'
              'E$episodeNumber';
          final docRef = _watchedEpisodesRef(uid).doc(episodeKey);
          batch.set(docRef, {
            'seriesTmdbId': seriesTmdbId,
            'seasonNumber': seasonNumber,
            'episodeNumber': episodeNumber,
            'watchedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        await batch.commit();
      }

      await _updateStats(uid);
    } catch (e) {
      throw Exception('Failed to mark episodes as watched: $e');
    }
  }

  Future<void> unmarkEpisodesWatchedBatch(
    int seriesTmdbId,
    List<Map<String, int>> episodes,
  ) async {
    if (seriesTmdbId <= 0) {
      throw ArgumentError('Invalid seriesTmdbId: must be greater than 0');
    }
    if (episodes.isEmpty) return;

    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      for (final chunk in _chunk(episodes, _batchSizeLimit)) {
        final batch = _firestore.batch();
        for (final episode in chunk) {
          final seasonNumber = episode['seasonNumber'] ?? -1;
          final episodeNumber = episode['episodeNumber'] ?? -1;
          if (seasonNumber < 0 || episodeNumber <= 0) continue;

          final episodeKey =
              '${seriesTmdbId}_S$seasonNumber'
              'E$episodeNumber';
          final docRef = _watchedEpisodesRef(uid).doc(episodeKey);
          batch.delete(docRef);
        }
        await batch.commit();
      }

      await _updateStats(uid);
    } catch (e) {
      throw Exception('Failed to unmark episodes: $e');
    }
  }

  Future<bool> isMovieWatched(int tmdbId) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final doc = await _watchedMoviesRef(uid).doc(tmdbId.toString()).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isEpisodeWatched(
    int seriesTmdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final episodeKey =
          '${seriesTmdbId}_S$seasonNumber'
          'E$episodeNumber';
      final doc = await _watchedEpisodesRef(uid).doc(episodeKey).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<List<WatchedMovie>> getWatchedMovies() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final favorites = await getFavoritedMovies();
      final favoriteIds = favorites.map((f) => f.tmdbId).toSet();

      final snapshot = await _watchedMoviesRef(uid).get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final id =
                (data['tmdbId'] as num?)?.toInt() ?? int.tryParse(doc.id) ?? 0;
            if (id <= 0) return null;
            return WatchedMovie(
              tmdbId: id,
              watchedAt: _parseDate(data['watchedAt']),
              isFavorite: favoriteIds.contains(id),
            );
          })
          .whereType<WatchedMovie>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<WatchedEpisode>> getWatchedEpisodes() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final snapshot = await _watchedEpisodesRef(uid).get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final seriesId = (data['seriesTmdbId'] as num?)?.toInt() ?? 0;
            final seasonNumber = (data['seasonNumber'] as num?)?.toInt() ?? 0;
            final episodeNumber = (data['episodeNumber'] as num?)?.toInt() ?? 0;
            if (seriesId <= 0 || episodeNumber <= 0) return null;
            return WatchedEpisode(
              seriesTmdbId: seriesId,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
              watchedAt: _parseDate(data['watchedAt']),
            );
          })
          .whereType<WatchedEpisode>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<WatchStats> getWatchStats() async {
    final movies = await getWatchedMovies();
    final episodes = await getWatchedEpisodes();

    return WatchStats(movies: movies, episodes: episodes);
  }

  Future<void> clearWatchHistory() async {
    final uid = _uid;
    if (uid == null) return;
    await _deleteCollection(_watchedMoviesRef(uid));
    await _deleteCollection(_watchedEpisodesRef(uid));
    await _deleteCollection(_favoriteMoviesRef(uid));
    await _deleteCollection(_favoriteSeriesRef(uid));
  }

  Future<void> markSeriesFavorite(int seriesTmdbId) async {
    if (seriesTmdbId <= 0) {
      throw ArgumentError('Invalid seriesTmdbId: must be greater than 0');
    }
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    try {
      await _favoriteSeriesRef(uid).doc(seriesTmdbId.toString()).set({
        'seriesTmdbId': seriesTmdbId,
        'favoritedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to mark series as favorite: $e');
    }
  }

  Future<void> unmarkSeriesFavorite(int seriesTmdbId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    try {
      await _favoriteSeriesRef(uid).doc(seriesTmdbId.toString()).delete();
    } catch (e) {
      throw Exception('Failed to unmark series favorite: $e');
    }
  }

  Future<bool> isSeriesFavorited(int seriesTmdbId) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final doc = await _favoriteSeriesRef(
        uid,
      ).doc(seriesTmdbId.toString()).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> markMovieFavorite(int tmdbId) async {
    if (tmdbId <= 0) {
      throw ArgumentError('Invalid tmdbId: must be greater than 0');
    }
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    try {
      await _favoriteMoviesRef(uid).doc(tmdbId.toString()).set({
        'tmdbId': tmdbId,
        'favoritedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to mark movie as favorite: $e');
    }
  }

  Future<void> unmarkMovieFavorite(int tmdbId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    try {
      await _favoriteMoviesRef(uid).doc(tmdbId.toString()).delete();
    } catch (e) {
      throw Exception('Failed to unmark movie favorite: $e');
    }
  }

  Future<bool> isMovieFavorited(int tmdbId) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final doc = await _favoriteMoviesRef(uid).doc(tmdbId.toString()).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<List<FavoritedMovie>> getFavoritedMovies() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final snapshot = await _favoriteMoviesRef(uid).get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final id =
                (data['tmdbId'] as num?)?.toInt() ?? int.tryParse(doc.id) ?? 0;
            if (id <= 0) return null;
            return FavoritedMovie(
              tmdbId: id,
              favoritedAt: _parseDate(data['favoritedAt']),
            );
          })
          .whereType<FavoritedMovie>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<FavoritedSeries>> getFavoritedSeries() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final snapshot = await _favoriteSeriesRef(uid).get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final id =
                (data['seriesTmdbId'] as num?)?.toInt() ??
                int.tryParse(doc.id) ??
                0;
            if (id <= 0) return null;
            return FavoritedSeries(
              seriesTmdbId: id,
              favoritedAt: _parseDate(data['favoritedAt']),
            );
          })
          .whereType<FavoritedSeries>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _updateStats(String uid) async {
    try {
      final movies = await getWatchedMovies();
      final episodes = await getWatchedEpisodes();
      final seriesIds = episodes.map((e) => e.seriesTmdbId).toSet();

      final moviesWatchedCount = movies.length;
      final episodesWatchedCount = episodes.length;
      final seriesWatchedCount = seriesIds.length;
      final movieWatchMinutes = moviesWatchedCount * 120;
      final seriesWatchMinutes = episodesWatchedCount * 45;

      await _statsDocRef(uid).set({
        'moviesWatchedCount': moviesWatchedCount,
        'episodesWatchedCount': episodesWatchedCount,
        'seriesWatchedCount': seriesWatchedCount,
        'movieWatchMinutes': movieWatchMinutes,
        'seriesWatchMinutes': seriesWatchMinutes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    // ignore: empty_catches
    } catch (e) {
    }
  }
}
