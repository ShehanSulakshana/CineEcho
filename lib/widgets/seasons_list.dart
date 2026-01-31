import 'package:cine_echo/models/watch_history_repository.dart';
import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeasonsList extends StatefulWidget {
  final String tvId;
  final List<dynamic> seasons;
  final Key? refreshKey;
  final VoidCallback? onEpisodesChanged;

  const SeasonsList({
    super.key,
    required this.tvId,
    required this.seasons,
    this.refreshKey,
    this.onEpisodesChanged,
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
  final Map<String, bool> _watchedEpisodes = {};

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
    try {
      final episodes = await _watchRepo.getWatchedEpisodes();
      if (!mounted) return;

      setState(() {
        _watchedEpisodes.clear();
        try {
          final seriesId = int.parse(widget.tvId);
          for (var ep in episodes) {
            if (ep.seriesTmdbId == seriesId) {
              _watchedEpisodes[ep.episodeKey] = true;
            }
          }
        } catch (e) {
          debugPrint('Error parsing series ID: $e');
        }
      });
    } catch (e) {
      debugPrint('Error loading watched episodes: $e');
      if (mounted) {
        setState(() {
          _watchedEpisodes.clear();
        });
      }
    }
  }

  bool _isSeasonCompleted(int seasonNumber, int episodeCount) {
    try {
      final seriesId = int.parse(widget.tvId);
      int watchedCount = 0;

      for (int i = 1; i <= episodeCount; i++) {
        final episodeKey = '${seriesId}_S${seasonNumber}E$i';
        if (_watchedEpisodes[episodeKey] ?? false) {
          watchedCount++;
        }
      }

      return watchedCount == episodeCount && episodeCount > 0;
    } catch (e) {
      debugPrint('Error checking season completion: $e');
      return false;
    }
  }

  bool _areAllEpisodesReleased(int seasonNumber) {
    final episodes = _episodesCache[seasonNumber];
    if (episodes == null || episodes.isEmpty) return false;

    final now = DateTime.now();
    for (var episode in episodes) {
      final airDate = episode['air_date'];
      if (airDate != null && airDate.isNotEmpty) {
        try {
          final date = DateTime.parse(airDate);
          if (date.isAfter(now)) {
            return false; // Found unreleased episode
          }
        } catch (e) {
          // If parsing fails, assume not released
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _toggleSeasonWatched(int seasonNumber) async {
    late final bool shouldShowDialog;
    try {
      final seriesId = int.parse(widget.tvId);
      final episodes = _episodesCache[seasonNumber];
      if (episodes == null || episodes.isEmpty) return;

      // Check if all episodes are released
      if (!_areAllEpisodesReleased(seasonNumber)) {
        _showBlockedSnackBar('Cannot mark season with unreleased episodes');
        return;
      }

      // Check current completion status
      final isCurrentlyCompleted = _isSeasonCompleted(
        seasonNumber,
        episodes.length,
      );

      // Collect all updates first
      final Map<String, bool> updates = {};
      final targetState = !isCurrentlyCompleted;

      // Prepare updates
      for (var episode in episodes) {
        final episodeNumber = episode['episode_number'] ?? 0;
        final key = '${seriesId}_S${seasonNumber}E$episodeNumber';
        updates[key] = targetState;
      }

      // Optimistic UI update - show immediately
      if (mounted) {
        setState(() {
          _watchedEpisodes.addAll(updates);
        });
      }

      // Show loading dialog if there are many episodes
      shouldShowDialog = episodes.length > 5;
      if (shouldShowDialog && mounted) {
        _showProcessingDialog(seasonNumber, episodes.length, targetState);
      }

      // Process in database
      for (var episode in episodes) {
        final episodeNumber = episode['episode_number'] ?? 0;

        if (targetState) {
          await _watchRepo.markEpisodeWatched(
            seriesId,
            seasonNumber,
            episodeNumber,
          );
        } else {
          await _watchRepo.unmarkEpisodeWatched(
            seriesId,
            seasonNumber,
            episodeNumber,
          );
        }
      }

      // Close dialog safely
      if (shouldShowDialog && mounted) {
        try {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          debugPrint('Error closing dialog: $e');
        }
      }

      // Note: Not calling onEpisodesChanged to preserve expanded state
      // The parent will refresh on next navigation or manual refresh
    } catch (e) {
      debugPrint('Error toggling season watched: $e');

      // Close dialog on error
      if (shouldShowDialog && mounted) {
        try {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } catch (dialogError) {
          debugPrint('Error closing dialog after error: $dialogError');
        }
      }

      // Revert UI on error
      if (mounted) {
        _loadWatchedEpisodes();
        _showBlockedSnackBar('Failed to update season. Please try again.');
      }
    }
  }

  void _showProcessingDialog(int seasonNumber, int episodeCount, bool marking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 3, color: blueColor),
                const SizedBox(height: 20),
                Text(
                  marking
                      ? 'Marking Season $seasonNumber'
                      : 'Unmarking Season $seasonNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Processing $episodeCount episodes...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleEpisodeWatched(
    int seasonNumber,
    int episodeNumber,
  ) async {
    late final bool isWatched;
    late final String key;
    try {
      final seriesId = int.parse(widget.tvId);
      key = '${seriesId}_S${seasonNumber}E$episodeNumber';
      isWatched = _watchedEpisodes[key] ?? false;

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
      // Note: Not calling onEpisodesChanged to preserve expanded state
    } catch (e) {
      debugPrint('Error toggling episode watched: $e');
      if (mounted) {
        _showBlockedSnackBar('Failed to update episode. Please try again.');
        // Revert the UI change
        setState(() {
          _watchedEpisodes[key] = isWatched;
        });
      }
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
          backgroundColor: Colors.orange.withAlpha(242),
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

      if (!mounted) return;

      final episodes = seasonDetails['episodes'];
      if (episodes == null || episodes is! List) {
        throw Exception('Invalid episode data received');
      }

      setState(() {
        _episodesCache[seasonNumber] = episodes;
        _expandedSeasons[seasonNumber] = true;
        _loadingSeasons[seasonNumber] = false;
      });
    } catch (e) {
      debugPrint('Error fetching season details: $e');
      if (mounted) {
        setState(() {
          _loadingSeasons[seasonNumber] = false;
        });
        _showBlockedSnackBar('Failed to load episodes. Check your connection.');
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
    // Safe type casting with defaults
    final seasonNumber = (season['season_number'] is int)
        ? season['season_number'] as int
        : 0;
    final name = season['name']?.toString() ?? 'Season $seasonNumber';
    final episodeCount = (season['episode_count'] is int)
        ? season['episode_count'] as int
        : 0;
    final airDate = season['air_date']?.toString();
    final posterPath = season['poster_path']?.toString();
    final isExpanded = _expandedSeasons[seasonNumber] == true;
    final isLoading = _loadingSeasons[seasonNumber] == true;
    final isCompleted = _isSeasonCompleted(seasonNumber, episodeCount);
    final canMarkSeason = isExpanded && _areAllEpisodesReleased(seasonNumber);

    final borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: Colors.white.withAlpha(13),
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
                    ? blueColor.withAlpha(128)
                    : Colors.white.withAlpha(26),
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
                          color: Colors.white.withAlpha(26),
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
                    width: 50,
                    height: 75,
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
                                color: Colors.green.withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withAlpha(128),
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
                          color: Colors.white.withAlpha(153),
                        ),
                      ),
                      if (airDate != null && airDate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(airDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(128),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (canMarkSeason)
                  Tooltip(
                    message: isCompleted
                        ? 'Unmark all episodes'
                        : 'Mark all episodes as watched',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _toggleSeasonWatched(seasonNumber);
                        },
                        borderRadius: BorderRadius.circular(10),
                        splashColor: blueColor.withAlpha(51),
                        highlightColor: blueColor.withAlpha(26),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? blueColor
                                  : Colors.white.withAlpha(13),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCompleted
                                    ? blueColor
                                    : Colors.white.withAlpha(77),
                                width: 2.5,
                              ),
                              boxShadow: isCompleted
                                  ? [
                                      BoxShadow(
                                        color: blueColor.withAlpha(128),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: AnimatedScale(
                              scale: isCompleted ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: Colors.white,
                                key: ValueKey('check_$isCompleted'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                if (isLoading)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: blueColor,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withAlpha(153),
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeItem(Map<String, dynamic> episode, int seasonNumber) {
    // Safe type casting with defaults
    final episodeNumber = (episode['episode_number'] is int)
        ? episode['episode_number'] as int
        : 0;
    final name = episode['name']?.toString() ?? 'Episode $episodeNumber';
    final overview = episode['overview']?.toString() ?? '';
    final airDate = episode['air_date']?.toString();
    final stillPath = episode['still_path']?.toString();
    final runtime = (episode['runtime'] is int)
        ? episode['runtime'] as int
        : null;
    final voteAverage = (episode['vote_average'] is num)
        ? (episode['vote_average'] as num).toDouble()
        : null;

    late final int seriesId;
    late final String episodeKey;
    late final bool isWatched;

    try {
      seriesId = int.parse(widget.tvId);
      episodeKey = '${seriesId}_S${seasonNumber}E$episodeNumber';
      isWatched = _watchedEpisodes[episodeKey] ?? false;
    } catch (e) {
      debugPrint('Error parsing series ID: $e');
      seriesId = 0;
      episodeKey = '';
      isWatched = false;
    }

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

    // ignore: no_leading_underscores_for_local_identifiers
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
        color: isWatched ? blueColor.withAlpha(20) : Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWatched
              ? blueColor.withAlpha(77)
              : Colors.white.withAlpha(13),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: Colors.white.withAlpha(13),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white.withAlpha(51),
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
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white.withAlpha(51),
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
                        color: blueColor.withAlpha(51),
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
                          decorationColor: Colors.white.withAlpha(128),
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
                          color: Colors.orange.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.orange.withAlpha(128),
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
                          color: Colors.white.withAlpha(128),
                        ),
                      ),
                    if (runtime != null && runtime > 0)
                      Text(
                        '• ${runtime}min',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withAlpha(128),
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
                              color: Colors.white.withAlpha(153),
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
                      color: Colors.white.withAlpha(128),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: isUnreleased
                ? _blockedMessage()
                : isWatched
                ? 'Mark as unwatched'
                : 'Mark as watched',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (isUnreleased) {
                    _showBlockedSnackBar(_blockedMessage());
                    return;
                  }
                  _toggleEpisodeWatched(seasonNumber, episodeNumber);
                },
                borderRadius: BorderRadius.circular(8),
                splashColor: isUnreleased
                    ? Colors.orange.withAlpha(51)
                    : blueColor.withAlpha(51),
                highlightColor: isUnreleased
                    ? Colors.orange.withAlpha(26)
                    : blueColor.withAlpha(26),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedOpacity(
                    opacity: isUnreleased ? 0.5 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(top: 14),
                      decoration: BoxDecoration(
                        color: isWatched
                            ? blueColor
                            : isUnreleased
                            ? Colors.white.withAlpha(20)
                            : Colors.white.withAlpha(13),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isWatched
                              ? blueColor
                              : isUnreleased
                              ? Colors.orange.withAlpha(153)
                              : Colors.white.withAlpha(77),
                          width: 2.5,
                        ),
                        boxShadow: isWatched
                            ? [
                                BoxShadow(
                                  color: blueColor.withAlpha(128),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: AnimatedScale(
                        scale: isWatched || isUnreleased ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          isWatched
                              ? Icons.check_rounded
                              : Icons.lock_clock_rounded,
                          size: isUnreleased ? 16 : 18,
                          color: isWatched ? Colors.white : Colors.orange,
                          key: ValueKey('icon_${isWatched}_$isUnreleased'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
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
