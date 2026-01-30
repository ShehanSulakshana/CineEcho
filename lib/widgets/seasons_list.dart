import 'package:cine_echo/models/watch_history_repository.dart';
import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeasonsList extends StatefulWidget {
  final String tvId;
  final List<dynamic> seasons;
  final Key? refreshKey;

  const SeasonsList({
    super.key,
    required this.tvId,
    required this.seasons,
    this.refreshKey,
  });

  @override
  State<SeasonsList> createState() => _SeasonsListState();
}

class _SeasonsListState extends State<SeasonsList> {
  final TmdbServices _tmdbServices = TmdbServices();
  final WatchHistoryRepository _watchRepo = WatchHistoryRepository();
  final Map<int, bool> _expandedSeasons = {};
  final Map<int, List<dynamic>> _episodesCache = {};
  final Map<int, bool> _loadingSeasons = {};
  final Map<String, bool> _watchedEpisodes = {}; // Track watched status

  @override
  void initState() {
    super.initState();
    _loadWatchedEpisodes();
  }

  @override
  void didUpdateWidget(SeasonsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshKey != oldWidget.refreshKey) {
      _loadWatchedEpisodes();
    }
  }

  Future<void> _loadWatchedEpisodes() async {
    final episodes = await _watchRepo.getWatchedEpisodes();
    if (mounted) {
      setState(() {
        _watchedEpisodes.clear();
        for (var ep in episodes) {
          if (ep.seriesTmdbId == int.parse(widget.tvId)) {
            _watchedEpisodes[ep.episodeKey] = true;
          }
        }
      });
    }
  }

  bool _isSeasonCompleted(int seasonNumber, int episodeCount) {
    // Check completion based on watched episodes count vs total episode count
    final seriesId = int.parse(widget.tvId);
    int watchedCount = 0;

    for (int i = 1; i <= episodeCount; i++) {
      final episodeKey = '${seriesId}_S${seasonNumber}E$i';
      if (_watchedEpisodes[episodeKey] ?? false) {
        watchedCount++;
      }
    }

    return watchedCount == episodeCount && episodeCount > 0;
  }

  Future<void> _toggleEpisodeWatched(
    int seasonNumber,
    int episodeNumber,
  ) async {
    final seriesId = int.parse(widget.tvId);
    final key = '${seriesId}_S${seasonNumber}E$episodeNumber';
    final isWatched = _watchedEpisodes[key] ?? false;

    if (isWatched) {
      await _watchRepo.unmarkEpisodeWatched(
        seriesId,
        seasonNumber,
        episodeNumber,
      );
      setState(() {
        _watchedEpisodes[key] = false;
      });
    } else {
      await _watchRepo.markEpisodeWatched(
        seriesId,
        seasonNumber,
        episodeNumber,
      );
      setState(() {
        _watchedEpisodes[key] = true;
      });
    }
  }

  void _showBlockedSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.orange.withOpacity(0.95),
          content: Row(
            children: [
              const Icon(
                Icons.lock_clock_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _toggleSeason(int seasonNumber) async {
    if (_expandedSeasons[seasonNumber] == true) {
      setState(() {
        _expandedSeasons[seasonNumber] = false;
      });
      return;
    }

    if (_episodesCache.containsKey(seasonNumber)) {
      setState(() {
        _expandedSeasons[seasonNumber] = true;
      });
      return;
    }

    setState(() {
      _loadingSeasons[seasonNumber] = true;
    });

    try {
      final seasonDetails = await _tmdbServices.fetchSeasonDetails(
        widget.tvId,
        seasonNumber,
      );
      final episodes = seasonDetails['episodes'] ?? [];

      if (mounted) {
        setState(() {
          _episodesCache[seasonNumber] = episodes;
          _expandedSeasons[seasonNumber] = true;
          _loadingSeasons[seasonNumber] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSeasons[seasonNumber] = false;
        });
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final formatter = DateFormat('MMM d, yyyy');

      if (date.isAfter(now)) {
        return 'Coming ${formatter.format(date)}';
      }
      return formatter.format(date);
    } catch (e) {
      return '';
    }
  }

  Widget _buildSeasonHeader(Map<String, dynamic> season) {
    final seasonNumber = season['season_number'] ?? 0;
    final name = season['name'] ?? 'Season $seasonNumber';
    final episodeCount = season['episode_count'] ?? 0;
    final airDate = season['air_date'];
    final posterPath = season['poster_path'];
    final isExpanded = _expandedSeasons[seasonNumber] == true;
    final isLoading = _loadingSeasons[seasonNumber] == true;
    final isCompleted = _isSeasonCompleted(seasonNumber, episodeCount);

    final borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: Colors.white.withOpacity(0.05),
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () => _toggleSeason(seasonNumber),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: isExpanded
                    ? blueColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
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
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 75,
                          color: Colors.white.withOpacity(0.1),
                          child: Icon(
                            Icons.movie_outlined,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 50,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.movie_outlined,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Completed',
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
                      const SizedBox(height: 4),
                      Text(
                        '$episodeCount episode${episodeCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      if (airDate != null && airDate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(airDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: blueColor,
                    ),
                  )
                else
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeItem(Map<String, dynamic> episode, int seasonNumber) {
    final episodeNumber = episode['episode_number'] ?? 0;
    final name = episode['name'] ?? 'Episode $episodeNumber';
    final overview = episode['overview'] ?? '';
    final airDate = episode['air_date'];
    final stillPath = episode['still_path'];
    final runtime = episode['runtime'];
    final voteAverage = episode['vote_average'];

    final seriesId = int.parse(widget.tvId);
    final episodeKey = '${seriesId}_S${seasonNumber}E$episodeNumber';
    final isWatched = _watchedEpisodes[episodeKey] ?? false;

    final now = DateTime.now();
    bool isUnreleased = false;
    String dateText = '';

    if (airDate != null && airDate.isNotEmpty) {
      try {
        final date = DateTime.parse(airDate);
        isUnreleased = date.isAfter(now);
        dateText = _formatDate(airDate);
      } catch (e) {
        dateText = '';
      }
    }

    String _blockedMessage() {
      if (dateText.isNotEmpty) {
        if (dateText.startsWith('Coming ')) {
          final cleanDate = dateText.replaceFirst('Coming ', '');
          return 'This episode releases on $cleanDate.';
        }
        return 'This episode releases on $dateText.';
      }
      return 'This episode hasn\'t aired yet.';
    }

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 16, bottom: 8, top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isWatched
            ? blueColor.withOpacity(0.08)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWatched
              ? blueColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox for watched status
          GestureDetector(
            onTap: () {
              if (isUnreleased) {
                _showBlockedSnackBar(_blockedMessage());
                return;
              }
              _toggleEpisodeWatched(seasonNumber, episodeNumber);
            },
            child: Opacity(
              opacity: isUnreleased ? 0.55 : 1,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12, top: 18),
                decoration: BoxDecoration(
                  color: isWatched
                      ? blueColor
                      : isUnreleased
                      ? Colors.white.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isWatched
                        ? blueColor
                        : isUnreleased
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: isWatched
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : isUnreleased
                    ? const Icon(
                        Icons.lock_clock_rounded,
                        size: 14,
                        color: Colors.orange,
                      )
                    : null,
              ),
            ),
          ),
          // Episode thumbnail
          if (stillPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                'https://image.tmdb.org/t/p/w185$stillPath',
                width: 100,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 60,
                    color: Colors.white.withOpacity(0.05),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white.withOpacity(0.2),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: 100,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white.withOpacity(0.2),
                  size: 24,
                ),
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
                        color: blueColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'E$episodeNumber',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: isWatched
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (isUnreleased)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Unreleased',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    if (dateText.isNotEmpty)
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    if (runtime != null && runtime > 0)
                      Text(
                        '• ${runtime}min',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    if (voteAverage != null && voteAverage > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            voteAverage.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (overview.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredSeasons = widget.seasons
        .where((season) => season['season_number'] != null)
        .toList();

    if (filteredSeasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Seasons',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredSeasons.length,
          itemBuilder: (context, index) {
            final season = filteredSeasons[index];
            final seasonNumber = season['season_number'];

            return Column(
              children: [
                _buildSeasonHeader(season),
                if (_expandedSeasons[seasonNumber] == true &&
                    _episodesCache.containsKey(seasonNumber))
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _episodesCache[seasonNumber]!.length,
                    itemBuilder: (context, episodeIndex) {
                      return _buildEpisodeItem(
                        _episodesCache[seasonNumber]![episodeIndex],
                        seasonNumber,
                      );
                    },
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 0),
      ],
    );
  }
}
