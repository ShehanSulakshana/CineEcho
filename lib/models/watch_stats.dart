import 'package:cine_echo/models/watched_movie.dart';
import 'package:cine_echo/models/watched_episode.dart';

class WatchStats {
  final List<WatchedMovie> movies;
  final List<WatchedEpisode> episodes;

  WatchStats({required this.movies, required this.episodes});

  int get moviesWatchedCount => movies.length;
  int get episodesWatchedCount => episodes.length;

  int get seriesWatchedCount {
    final uniqueSeriesIds = episodes.map((e) => e.seriesTmdbId).toSet();
    return uniqueSeriesIds.length;
  }

  Map<int, int> get episodesPerSeries {
    final map = <int, int>{};
    for (var episode in episodes) {
      map[episode.seriesTmdbId] = (map[episode.seriesTmdbId] ?? 0) + 1;
    }
    return map;
  }
}
