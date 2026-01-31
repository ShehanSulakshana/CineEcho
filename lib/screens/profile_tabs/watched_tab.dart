import 'package:cine_echo/models/watch_history_repository.dart';
import 'package:cine_echo/models/watched_episode.dart';
import 'package:cine_echo/models/watched_movie.dart';
import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/screens/specific/details_screen.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:flutter/material.dart';

class WatchedTab extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const WatchedTab({super.key, this.onDataChanged});

  @override
  State<WatchedTab> createState() => _WatchedTabState();
}

class _WatchedTabState extends State<WatchedTab> {
  final WatchHistoryRepository _watchRepo = WatchHistoryRepository();
  final TmdbServices _tmdbServices = TmdbServices();
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final movies = await _watchRepo.getWatchedMovies();
    final episodes = await _watchRepo.getWatchedEpisodes();
    final groupedBySeries = <int, List<WatchedEpisode>>{};
    for (var episode in episodes) {
      groupedBySeries.putIfAbsent(episode.seriesTmdbId, () => []).add(episode);
    }

    List<dynamic> combinedItems = [];
    combinedItems.addAll(
      movies.map((movie) => {'type': 'movie', 'data': movie}),
    );
    combinedItems.addAll(
      groupedBySeries.entries.map(
        (entry) => {
          'type': 'series',
          'seriesId': entry.key,
          'episodes': entry.value,
        },
      ),
    );

    combinedItems.sort(_compareByMostRecentlyWatched);

    if (mounted) {
      setState(() {
        _items = combinedItems;
        _isLoading = false;
      });
    }
  }

  int _compareByMostRecentlyWatched(dynamic a, dynamic b) {
    DateTime aDate = _getItemWatchDate(a);
    DateTime bDate = _getItemWatchDate(b);
    return bDate.compareTo(aDate);
  }

  DateTime _getItemWatchDate(dynamic item) {
    if (item['type'] == 'movie') {
      return (item['data'] as WatchedMovie).watchedAt;
    }
    final episodes = item['episodes'] as List<WatchedEpisode>;
    return episodes
        .map((e) => e.watchedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  void _showDeleteDialog(String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red[400], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Remove Item',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Remove "$title" from your watched list?',
          style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemovalLoadingDialog({required bool isSeries}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 16, 26, 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSeries
                          ? 'Clearing watched episodes'
                          : 'Removing from watched',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Syncing your progress…',
                      style: TextStyle(
                        color: Colors.white.withAlpha(178),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outlined,
                size: 64,
                color: Colors.white.withAlpha(77),
              ),
              const SizedBox(height: 16),
              Text(
                'Nothing watched yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(153),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start watching movies and series!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(102),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        if (item['type'] == 'movie') {
          return _buildMovieCard(item['data'] as WatchedMovie);
        } else {
          return _buildSeriesCard(
            item['seriesId'] as int,
            item['episodes'] as List<WatchedEpisode>,
          );
        }
      },
    );
  }

  Widget _buildMovieCard(WatchedMovie movie) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _tmdbServices.fetchDetails(
        movie.tmdbId.toString(),
        'movie',
        isSeason: false,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final data = snapshot.data!;
        final posterPath = data['poster_path'];
        final title = data['title'] ?? 'Unknown';
        final releaseDate = data['release_date'] ?? '';
        final rating = data['vote_average']?.toStringAsFixed(1) ?? 'N/A';
        final runtime = data['runtime'] ?? 0;

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  dataMap: data,
                  typeData: 'movie',
                  id: movie.tmdbId.toString(),
                  heroSource: 'watched_movie_${movie.tmdbId}',
                ),
              ),
            );
            if (mounted) {
              _loadContent();
            }
          },
          onLongPress: () {
            _showDeleteDialog(title, () async {
              _showRemovalLoadingDialog(isSeries: false);
              try {
                await _watchRepo.unmarkMovieWatched(movie.tmdbId);
              } finally {
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              }
              if (mounted) {
                _loadContent();
                widget.onDataChanged?.call();
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: movie.isFavorite
                    ? Colors.red.withAlpha(128)
                    : blueColor.withAlpha(77),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (posterPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w92$posterPath',
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.movie_outlined,
                            color: Colors.white.withAlpha(77),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.movie_outlined,
                      color: Colors.white.withAlpha(77),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: blueColor.withAlpha(51),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MOVIE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: blueColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (movie.isFavorite)
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (releaseDate.isNotEmpty) ...[
                            Text(
                              releaseDate.substring(0, 4),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha(153),
                              ),
                            ),
                            if (runtime > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(153),
                                ),
                              ),
                            ],
                          ],
                          if (runtime > 0) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.white.withAlpha(153),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${runtime}min',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha(153),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(204),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(51),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.green.withAlpha(128),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Watched',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeriesCard(int seriesId, List<WatchedEpisode> episodes) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _tmdbServices.fetchDetails(
        seriesId.toString(),
        'tv',
        isSeason: false,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final data = snapshot.data!;
        final posterPath = data['poster_path'];
        final name = data['name'] ?? 'Unknown';
        final firstAirDate = data['first_air_date'] ?? '';
        final seasons = data['seasons'] as List<dynamic>? ?? [];

        int totalEpisodes = 0;
        for (var season in seasons) {
          if (season['season_number'] != 0) {
            totalEpisodes += (season['episode_count'] as int? ?? 0);
          }
        }

        final watchedCount = episodes.length;
        final isCompleted = totalEpisodes > 0 && watchedCount >= totalEpisodes;
        final totalWatchMinutes = watchedCount * 45;
        final hours = totalWatchMinutes ~/ 60;
        final minutes = totalWatchMinutes % 60;
        final watchTimeString = hours > 0
            ? '${hours}h ${minutes}m'
            : '${minutes}m';

        return FutureBuilder<bool>(
          future: _watchRepo.isSeriesFavorited(seriesId),
          builder: (context, favSnapshot) {
            final isFavorite = favSnapshot.data ?? false;

            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(
                      dataMap: data,
                      typeData: 'tv',
                      id: seriesId.toString(),
                      heroSource: 'watched_series_$seriesId',
                    ),
                  ),
                );
                // Refresh data after returning from details
                if (mounted) {
                  _loadContent();
                }
              },
              onLongPress: () {
                _showDeleteDialog(name, () async {
                  _showRemovalLoadingDialog(isSeries: true);
                  try {
                    // Use Future.wait for parallel deletion instead of sequential
                    await Future.wait(
                      episodes.map(
                        (episode) => _watchRepo.unmarkEpisodeWatched(
                          seriesId,
                          episode.seasonNumber,
                          episode.episodeNumber,
                        ),
                      ),
                    );
                  } finally {
                    if (mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  }
                  if (mounted) {
                    _loadContent();
                    widget.onDataChanged?.call();
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFavorite
                        ? Colors.red.withAlpha(128)
                        : isCompleted
                        ? Colors.green.withAlpha(128)
                        : blueColor.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (posterPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w92$posterPath',
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(26),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.tv_outlined,
                                color: Colors.white.withAlpha(77),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.tv_outlined,
                          color: Colors.white.withAlpha(77),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: blueColor.withAlpha(51),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'TV SERIES',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isFavorite)
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 18,
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (firstAirDate.isNotEmpty)
                            Text(
                              firstAirDate.substring(0, 4),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha(153),
                              ),
                            ),
                          const SizedBox(height: 6),
                          if (isCompleted) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: Colors.white.withAlpha(153),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  watchTimeString,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withAlpha(204),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(51),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.green.withAlpha(128),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Watched',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Text(
                                  '$watchedCount of $totalEpisodes episodes',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withAlpha(153),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: blueColor.withAlpha(51),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: blueColor.withAlpha(128),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline,
                                        color: blueColor,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Watching',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
