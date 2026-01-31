import 'dart:ui';

import 'package:cine_echo/models/genre_list.dart';
import 'package:cine_echo/models/watch_history_repository.dart';
import 'package:cine_echo/providers/tmdb_provider.dart';
import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/cast_horizontal_slider.dart';
import 'package:cine_echo/widgets/horizontal_slider.dart';
import 'package:cine_echo/widgets/safe_network_image.dart';
import 'package:cine_echo/widgets/seasons_list.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:redacted/redacted.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.dataMap,
    required this.typeData,
    required this.id,
    required this.heroSource,
    this.unique = '',
    this.fromCast = false,
  });

  final Map<String, dynamic> dataMap;
  final String typeData;
  final String id;
  final String heroSource;
  final String unique;
  final bool fromCast;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isLoading = true;
  late Map<String, dynamic> moreDetailsMap;
  late String runtime;
  String trailerKey = '';
  List<dynamic> cast = const [];
  List<dynamic> recommendations = const [];
  int totalRecommendationPages = 1;
  Key _seasonsListKey = UniqueKey();
  Key _watchStatusKey = UniqueKey();

  String getType(String typeData) {
    final String type;
    if (typeData.contains('movie')) {
      type = 'movie';
    } else {
      type = 'tv';
    }
    return type;
  }

  void _refreshSeasonsList() {
    if (!mounted) return;
    setState(() {
      _seasonsListKey = UniqueKey();
      _watchStatusKey = UniqueKey();
    });
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    final tmdbProvider = Provider.of<TmdbProvider>(context, listen: false);
    moreDetailsMap = await tmdbProvider.fetchDetails(
      widget.id.toString(),
      getType(widget.typeData),
    );

    if (getType(widget.typeData) == 'movie') {
      final int minutes =
          int.tryParse(moreDetailsMap['runtime']?.toString() ?? '0') ?? 0;
      final int hours = minutes ~/ 60;
      final int mins = minutes % 60;
      runtime = '0${hours}h ${mins}m';
    }

    cast = moreDetailsMap['credits']?['cast'] ?? [];
    recommendations = moreDetailsMap['recommendations']?['results'] ?? [];
    totalRecommendationPages =
        moreDetailsMap['recommendations']?['total_pages'] ?? 1;

    trailerKey = getTrailerKey();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String getTrailerKey() {
    final dynamic results = moreDetailsMap['videos']?['results'];
    final List<dynamic> videos = results is List ? results : const <dynamic>[];
    if (videos.isEmpty) return '';
    try {
      final trailer = videos.firstWhere(
        (video) =>
            video['type'] == 'Trailer' &&
            video['site'] == 'YouTube' &&
            video['key'] != null,
        orElse: () => null,
      );
      return trailer?['key']?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.dataMap['title'] ?? widget.dataMap['name'] ?? 'Unknown';
    final rating = (widget.dataMap['vote_average'] ?? 0.0).toStringAsFixed(1);

    String getReleaseYear() {
      try {
        final dateStr =
            widget.dataMap['first_air_date'] ??
            widget.dataMap['release_date'] ??
            '';
        if (dateStr.isEmpty) return 'N/A';
        return DateTime.parse(dateStr).year.toString();
      } catch (e) {
        return 'N/A';
      }
    }

    final releaseYear = getReleaseYear();
    final bannerPath = widget.dataMap['backdrop_path'];
    final posterPath = widget.dataMap['poster_path'];
    final bannerLink = bannerPath == null
        ? ''
        : "https://image.tmdb.org/t/p/w780/$bannerPath";
    final posterLink = posterPath == null
        ? ''
        : "https://image.tmdb.org/t/p/w342/$posterPath";
    final overview =
        widget.dataMap['overview'] ?? 'Overview not available for this.';

    String getGenre() {
      var buffer = StringBuffer();
      final Map<int, dynamic> allGenreMap = GenreListClass.getGenreMap();

      List<dynamic>? genreList;

      if (widget.dataMap['genre_ids'] != null) {
        genreList = widget.dataMap['genre_ids'] as List<dynamic>?;
        if (genreList != null && genreList.isNotEmpty) {
          for (var i = 0; i < genreList.length; i++) {
            final genreId = genreList[i];
            final genreName = allGenreMap[genreId];
            if (i != genreList.length - 1) {
              buffer.write("$genreName, ");
            } else {
              buffer.write("$genreName");
            }
          }
        }
      } else if (widget.dataMap['genres'] != null) {
        final genres = widget.dataMap['genres'] as List<dynamic>?;
        if (genres != null && genres.isNotEmpty) {
          for (var i = 0; i < genres.length; i++) {
            final genreObj = genres[i] as Map<String, dynamic>;
            final genreName = genreObj['name'] ?? 'Unknown';
            if (i != genres.length - 1) {
              buffer.write("$genreName, ");
            } else {
              buffer.write("$genreName");
            }
          }
        }
      }

      return buffer.toString();
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double bgHeight = constraints.maxWidth * (3 / 4);
              double overlap = 90;
              return Stack(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: bgHeight,
                        width: constraints.maxWidth,
                        child: bannerLink.isEmpty
                            ? Image.asset(
                                'assets/splash/logo.png',
                                fit: BoxFit.cover,
                              ).redacted(context: context, redact: _isLoading)
                            : SafeNetworkImage(
                                imageUrl: bannerLink,
                                fit: BoxFit.cover,
                                placeholder: Image.asset(
                                  'assets/splash/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withAlpha(254),
                                Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withAlpha(230),
                                Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withAlpha(150),

                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.1, 0.3, 0.5],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withAlpha(60),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                ),
                                color: Theme.of(context).primaryColor,
                                focusColor: lightblueColor,
                                tooltip: 'Go back',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: bgHeight - overlap),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 180,
                              child: Hero(
                                tag:
                                    "${widget.heroSource}_poster_${widget.id}_${widget.unique}",
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    20,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 2 / 3,
                                    child: posterLink.isEmpty
                                        ? Image.asset(
                                            'assets/splash/logo.png',
                                            fit: BoxFit.cover,
                                          ).redacted(
                                            context: context,
                                            redact: _isLoading,
                                          )
                                        : SafeNetworkImage(
                                            imageUrl: posterLink,
                                            fit: BoxFit.cover,
                                            placeholder: Image.asset(
                                              'assets/splash/logo.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 15,
                                  bottom: 10,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRect(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: 30,
                                          maxHeight: 60,
                                        ),
                                        child: !_isLoading && title.length > 15
                                            ? Marquee(
                                                text: title,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge,
                                                scrollAxis: Axis.horizontal,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                blankSpace: 20.0,
                                                velocity: 30.0,
                                                pauseAfterRound: const Duration(
                                                  seconds: 1,
                                                ),
                                                accelerationDuration:
                                                    const Duration(seconds: 2),
                                                accelerationCurve:
                                                    Curves.linear,
                                                decelerationDuration:
                                                    const Duration(
                                                      milliseconds: 500,
                                                    ),
                                                decelerationCurve:
                                                    Curves.easeOut,
                                              )
                                            : Align(
                                                alignment: Alignment.centerLeft,
                                                child:
                                                    Text(
                                                      _isLoading
                                                          ? "Movie Name"
                                                          : title,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.bodyLarge,
                                                    ).redacted(
                                                      context: context,
                                                      redact: _isLoading,
                                                    ),
                                              ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        border: Border.all(color: ashColor),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 2,
                                      ),
                                      width: 65,
                                      child: _isLoading
                                          ? SizedBox(height: 10)
                                          : Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.yellow,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  rating,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ).redacted(
                                      context: context,
                                      redact: _isLoading,
                                    ),
                                    SizedBox(height: 5),

                                    Text(
                                      !_isLoading &&
                                              getType(widget.typeData) ==
                                                  'movie'
                                          ? "$releaseYear • $runtime"
                                          : !_isLoading &&
                                                getType(widget.typeData) == 'tv'
                                          ? releaseYear
                                          : "_",
                                      style: TextStyle(fontSize: 12),
                                    ).redacted(
                                      context: context,
                                      redact: _isLoading,
                                    ),

                                    SizedBox(height: 3),
                                    Text(
                                      getGenre(),
                                      style: TextStyle(fontSize: 13),
                                    ).redacted(
                                      context: context,
                                      redact: _isLoading,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Buttons(
                              key: _watchStatusKey,
                              trailerKey: trailerKey,
                              isLoading: _isLoading,
                              contentId: int.parse(widget.id),
                              contentType: getType(widget.typeData),
                              releaseDate: widget.dataMap['release_date'],
                              nextEpisodeToAir:
                                  getType(widget.typeData) == 'tv' &&
                                      !_isLoading
                                  ? moreDetailsMap['next_episode_to_air']
                                  : null,
                              seasonsData:
                                  getType(widget.typeData) == 'tv' &&
                                      !_isLoading
                                  ? moreDetailsMap['seasons']
                                  : null,
                              onWatchedChanged: _refreshSeasonsList,
                            ),

                            SizedBox(height: 30),
                            Text(
                              "Overview",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 0.3,
                                  ),
                              textAlign: TextAlign.start,
                            ).redacted(context: context, redact: _isLoading),
                            SizedBox(height: 12),
                            Text(
                              overview,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.justify,
                            ).redacted(context: context, redact: _isLoading),
                            SizedBox(height: 25),
                          ],
                        ),
                      ),

                      CastHorizontalSlider(
                        castList: cast,
                        isLoading: _isLoading,
                        fromCast: widget.fromCast,
                      ),

                      if (getType(widget.typeData) == 'tv' &&
                          !_isLoading &&
                          moreDetailsMap['seasons'] != null)
                        SeasonsList(
                          key: _seasonsListKey,
                          tvId: widget.id,
                          seasons: moreDetailsMap['seasons'] ?? [],
                          refreshKey: _seasonsListKey,
                          onEpisodesChanged: _refreshSeasonsList,
                        ),

                      SizedBox(height: 25),
                      !_isLoading && recommendations.isNotEmpty
                          ? HorizontalSliderWidget(
                              title: "Recommendations",
                              endpoint: "movie",
                              dataList: recommendations,
                              totalPages: totalRecommendationPages,
                              showmoreButton: false,
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class Buttons extends StatefulWidget {
  final String trailerKey;
  final bool isLoading;
  final int contentId;
  final String contentType;
  final List<dynamic>? seasonsData;
  final String? releaseDate;
  final Map<String, dynamic>? nextEpisodeToAir;
  final VoidCallback? onWatchedChanged;

  const Buttons({
    super.key,
    required this.trailerKey,
    required this.isLoading,
    required this.contentId,
    required this.contentType,
    this.seasonsData,
    this.releaseDate,
    this.nextEpisodeToAir,
    this.onWatchedChanged,
  });

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> with TickerProviderStateMixin {
  final WatchHistoryRepository _watchRepo = WatchHistoryRepository();
  late bool isFavorite;
  late bool markeAsWatched;
  bool _statusLoading = true;

  late AnimationController _favoriteController;
  late AnimationController _trailerController;
  late AnimationController _watchedController;

  @override
  void dispose() {
    _favoriteController.dispose();
    _watchedController.dispose();
    _trailerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isFavorite = false;
    markeAsWatched = false;

    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _watchedController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _trailerController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _loadStatus();
  }

  @override
  void didUpdateWidget(Buttons oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    if (mounted) {
      setState(() {
        _statusLoading = true;
      });
    }
    if (widget.contentType == 'movie') {
      final watched = await _watchRepo.isMovieWatched(widget.contentId);
      final favorite = await _watchRepo.isMovieFavorited(widget.contentId);

      if (mounted) {
        setState(() {
          markeAsWatched = watched;
          isFavorite = favorite;
          _statusLoading = false;
          if (markeAsWatched) {
            _watchedController.value = 1.0;
          }
          if (isFavorite) {
            _favoriteController.value = 1.0;
          }
        });
      }
    } else if (widget.contentType == 'tv') {
      final episodes = await _watchRepo.getWatchedEpisodes();
      final seriesEpisodes = episodes
          .where((e) => e.seriesTmdbId == widget.contentId)
          .toList();

      final watchedKeys = seriesEpisodes
          .map((episode) => episode.episodeKey)
          .toSet();
      bool allSeasonsCompleted = false;

      if (widget.seasonsData != null) {
        final seasons = widget.seasonsData!
            .where((season) => season['season_number'] != null)
            .where((season) => season['season_number'] != 0)
            .toList();

        if (seasons.isNotEmpty) {
          allSeasonsCompleted = seasons.every((season) {
            final seasonNumber = season['season_number'] as int;
            final episodeCount = season['episode_count'] as int? ?? 0;
            if (episodeCount <= 0) return false;

            for (int i = 1; i <= episodeCount; i++) {
              final key = '${widget.contentId}_S${seasonNumber}E$i';
              if (!watchedKeys.contains(key)) {
                return false;
              }
            }
            return true;
          });
        }
      }

      final isFav = await _watchRepo.isSeriesFavorited(widget.contentId);

      if (mounted) {
        setState(() {
          markeAsWatched = allSeasonsCompleted;
          isFavorite = isFav;
          _statusLoading = false;
          if (markeAsWatched) {
            _watchedController.value = 1.0;
          }
          if (isFavorite) {
            _favoriteController.value = 1.0;
          }
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final newFavoriteState = !isFavorite;

    setState(() {
      isFavorite = newFavoriteState;
    });

    if (isFavorite) {
      _favoriteController.forward();
    } else {
      _favoriteController.reverse();
    }

    if (widget.contentType == 'movie') {
      if (isFavorite) {
        await _watchRepo.markMovieFavorite(widget.contentId);
      } else {
        await _watchRepo.unmarkMovieFavorite(widget.contentId);
      }
    } else if (widget.contentType == 'tv') {
      if (isFavorite) {
        await _watchRepo.markSeriesFavorite(widget.contentId);
      } else {
        await _watchRepo.unmarkSeriesFavorite(widget.contentId);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).primaryColor.withAlpha(230),
          content: Row(
            children: [
              Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.heart_broken_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFavorite
                      ? "Added to your favorites"
                      : "Removed from favorites",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _toggleWatched() async {
    final newWatchedState = !markeAsWatched;

    if (newWatchedState && _isWatchBlocked()) {
      _showWatchBlockedMessage();
      return;
    }

    setState(() {
      markeAsWatched = newWatchedState;
    });

    final shouldShowLoading = markeAsWatched;
    if (shouldShowLoading) {
      _showWatchLoadingDialog(markeAsWatched);
      _watchedController.forward();
    } else {
      _watchedController.reverse();
    }

    try {
      if (widget.contentType == 'movie') {
        if (markeAsWatched) {
          await _watchRepo.markMovieWatched(widget.contentId);
        } else {
          await _watchRepo.unmarkMovieWatched(widget.contentId);
        }
      } else if (widget.contentType == 'tv') {
        if (markeAsWatched) {
          await _markAllEpisodes();
        } else {
          await _unmarkAllEpisodes();
        }
        widget.onWatchedChanged?.call();
      }
    } finally {
      if (shouldShowLoading && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).primaryColor.withAlpha(230),
          content: Row(
            children: [
              Icon(
                markeAsWatched
                    ? Icons.check_circle
                    : Icons.remove_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  markeAsWatched
                      ? widget.contentType == 'movie'
                            ? "Marked as watched"
                            : "All episodes marked as watched"
                      : widget.contentType == 'movie'
                      ? "Removed from watched list"
                      : "All episodes unmarked",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showWatchLoadingDialog(bool isMarking) {
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
                      isMarking
                          ? (widget.contentType == 'movie'
                                ? 'Marking as watched'
                                : 'Marking all episodes')
                          : (widget.contentType == 'movie'
                                ? 'Removing from watched'
                                : 'Clearing watched episodes'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMarking
                          ? 'Updating your progress…'
                          : 'Syncing your progress…',
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

  bool _isMovieUnreleased() {
    if (widget.contentType != 'movie') return false;
    final dateText = widget.releaseDate?.toString();
    if (dateText == null || dateText.isEmpty) return false;
    try {
      final date = DateTime.parse(dateText);
      return date.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  bool _hasUnreleasedFinalSeasonEpisodes() {
    if (widget.contentType != 'tv') return false;
    if (widget.seasonsData == null || widget.seasonsData!.isEmpty) return false;
    if (widget.nextEpisodeToAir == null) return false;

    int? finalSeasonNumber;
    for (final season in widget.seasonsData!) {
      final number = season['season_number'];
      if (number is int) {
        finalSeasonNumber = finalSeasonNumber == null
            ? number
            : (number > finalSeasonNumber ? number : finalSeasonNumber);
      }
    }

    if (finalSeasonNumber == null) return false;

    final nextSeason = widget.nextEpisodeToAir!['season_number'];
    if (nextSeason != finalSeasonNumber) return false;

    final airDate = widget.nextEpisodeToAir!['air_date'];
    if (airDate == null || airDate.toString().isEmpty) return true;
    try {
      final date = DateTime.parse(airDate.toString());
      return date.isAfter(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  bool _hasAnyUnreleasedEpisodes() {
    if (widget.contentType != 'tv') return false;

    if (widget.nextEpisodeToAir != null) {
      final airDate = widget.nextEpisodeToAir!['air_date'];

      if (airDate == null || airDate.toString().isEmpty) {
        return true;
      }

      try {
        final date = DateTime.parse(airDate.toString());
        if (date.isAfter(DateTime.now())) {
          return true;
        }
        return true;
      } catch (_) {
        return true;
      }
    }

    return false;
  }

  bool _isWatchBlocked() {
    return _isMovieUnreleased() || _hasUnreleasedFinalSeasonEpisodes();
  }

  String _formatReleaseDate(String? dateText) {
    if (dateText == null || dateText.isEmpty) return '';
    try {
      final date = DateTime.parse(dateText);
      final formatter = DateFormat('MMM d, yyyy');
      return formatter.format(date);
    } catch (_) {
      return '';
    }
  }

  void _showWatchBlockedMessage() {
    if (!mounted) return;

    String message = 'This title isn\'t released yet.';

    if (widget.contentType == 'movie') {
      final releaseText = _formatReleaseDate(widget.releaseDate);
      message = releaseText.isNotEmpty
          ? 'This movie releases on $releaseText.'
          : 'This movie isn\'t released yet.';
    } else if (widget.contentType == 'tv') {
      final nextAirDate = _formatReleaseDate(
        widget.nextEpisodeToAir?['air_date']?.toString(),
      );
      message = nextAirDate.isNotEmpty
          ? 'Final season episodes are still coming. Next airs on $nextAirDate.'
          : 'Final season episodes are still coming. You can mark all after they air.';
    }

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

  Future<void> _markAllEpisodes() async {
    if (widget.seasonsData == null) return;

    final tmdbServices = TmdbServices();
    final episodesToMark = <Map<String, int>>[];
    for (var season in widget.seasonsData!) {
      final seasonNumber = season['season_number'];
      if (seasonNumber == null) continue;

      final seasonDetails = await tmdbServices
          .fetchDetails(
            '${widget.contentId}/season/$seasonNumber',
            'tv',
            isSeason: true,
          )
          .catchError((_) => <String, dynamic>{});

      final episodes = seasonDetails['episodes'] as List<dynamic>? ?? [];
      final episodeCount = season['episode_count'] ?? 0;

      for (int i = 1; i <= episodeCount; i++) {
        final episodeData = i <= episodes.length ? episodes[i - 1] : null;
        final airDate = episodeData?['air_date']?.toString();

        if (airDate != null && airDate.isNotEmpty) {
          try {
            final date = DateTime.parse(airDate);
            if (date.isAfter(DateTime.now())) {
              continue;
            }
          } catch (_) {}
        }

        episodesToMark.add({
          'seasonNumber': seasonNumber as int,
          'episodeNumber': i,
        });
      }
    }

    if (episodesToMark.isEmpty) return;
    await _watchRepo.markEpisodesWatchedBatch(widget.contentId, episodesToMark);
  }

  Future<void> _unmarkAllEpisodes() async {
    final episodes = await _watchRepo.getWatchedEpisodes();
    final seriesEpisodes = episodes
        .where((e) => e.seriesTmdbId == widget.contentId)
        .toList();

    final episodesToUnmark = seriesEpisodes
        .map(
          (episode) => {
            'seasonNumber': episode.seasonNumber,
            'episodeNumber': episode.episodeNumber,
          },
        )
        .toList();

    if (episodesToUnmark.isEmpty) return;
    await _watchRepo.unmarkEpisodesWatchedBatch(
      widget.contentId,
      episodesToUnmark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isStatusLoading = widget.isLoading || _statusLoading;
    final bool isWatchBlocked = widget.contentType == 'movie'
        ? _isWatchBlocked() && !markeAsWatched
        : _hasAnyUnreleasedEpisodes() && !markeAsWatched;
    final String blockedTooltip = widget.contentType == 'movie'
        ? (() {
            final releaseText = _formatReleaseDate(widget.releaseDate);
            return releaseText.isNotEmpty
                ? 'Available on $releaseText'
                : 'Available after release';
          })()
        : (() {
            final nextAir = _formatReleaseDate(
              widget.nextEpisodeToAir?['air_date']?.toString(),
            );
            return nextAir.isNotEmpty
                ? 'Final season continues $nextAir'
                : 'Final season still airing';
          })();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: widget.isLoading ? 0.0 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoadingButton(
              isLoading: isStatusLoading,
              child: _AnimatedIconButton(
                isActive: isFavorite,
                controller: _favoriteController,
                activeIcon: Icons.favorite_rounded,
                inactiveIcon: Icons.favorite_border_rounded,
                onPressed: isStatusLoading ? null : _toggleFavorite,
                tooltip: isFavorite
                    ? "Remove from favorites"
                    : "Add to favorites",
                isDisabled: isStatusLoading,
              ),
            ),

            const SizedBox(width: 12),

            _buildLoadingButton(
              isLoading: isStatusLoading,
              child: _AnimatedIconButton(
                isActive: markeAsWatched,
                controller: _watchedController,
                activeIcon: Icons.done_all_rounded,
                inactiveIcon: Icons.done_rounded,
                onPressed: (isWatchBlocked || isStatusLoading)
                    ? null
                    : _toggleWatched,
                isDisabled: isWatchBlocked || isStatusLoading,
                tooltip: isStatusLoading
                    ? "Loading..."
                    : isWatchBlocked
                    ? blockedTooltip
                    : markeAsWatched
                    ? widget.contentType == 'movie'
                          ? "Mark as unwatched"
                          : "Unmark all episodes"
                    : widget.contentType == 'movie'
                    ? "Mark as watched"
                    : "Mark all episodes as watched",
              ),
            ),

            const SizedBox(width: 12),

            _buildLoadingTrailerButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingButton({required bool isLoading, required Widget child}) {
    return Opacity(
      opacity: isLoading ? 0.4 : 1.0,
      child: child.redacted(
        context: context,
        redact: isLoading,
        configuration: RedactedConfiguration(
          animationDuration: Duration(milliseconds: 800),
        ),
      ),
    );
  }

  Widget _buildLoadingTrailerButton() {
    return Expanded(
      child: Opacity(
        opacity: widget.isLoading ? 0.4 : 1.0,
        child: MouseRegion(
          onEnter: widget.isLoading
              ? null
              : (_) => _trailerController.forward(),
          onExit: widget.isLoading ? null : (_) => _trailerController.reverse(),
          child: AnimatedBuilder(
            animation: _trailerController,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isLoading
                    ? 1.0
                    : (1.0 + (_trailerController.value * 0.02)),
                child:
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withAlpha(
                              widget.isLoading
                                  ? 0
                                  : (77 + (_trailerController.value * 51))
                                        .round(),
                            ),
                            blurRadius:
                                8 +
                                (widget.isLoading
                                    ? 0
                                    : (_trailerController.value * 4)),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.resolveWith((states) {
                            if (widget.isLoading) return 0.0;
                            if (states.contains(WidgetState.pressed)) {
                              return 1.0;
                            }
                            return 3.0 + (_trailerController.value * 2);
                          }),
                          shadowColor: WidgetStatePropertyAll(
                            Theme.of(context).primaryColor.withAlpha(
                              widget.isLoading ? 0 : 128,
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (widget.isLoading) {
                              return Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withAlpha(100);
                            }
                            if (states.contains(WidgetState.pressed)) {
                              return Theme.of(
                                context,
                              ).primaryColor.withAlpha(204);
                            }
                            return Theme.of(context).primaryColor;
                          }),
                          foregroundColor: WidgetStatePropertyAll(
                            widget.isLoading
                                ? Colors.white.withAlpha(102)
                                : Colors.white,
                          ),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          overlayColor: WidgetStatePropertyAll(
                            Colors.white.withAlpha(26),
                          ),
                        ),
                        onPressed:
                            widget.trailerKey.isNotEmpty && !widget.isLoading
                            ? () async {
                                final Uri ytlink = Uri.parse(
                                  "https://www.youtube.com/watch?v=${widget.trailerKey}",
                                );
                                final launched = await launchUrl(
                                  ytlink,
                                  mode: LaunchMode.externalApplication,
                                );
                                if (!launched && mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Could not launch trailer',
                                        ),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                }
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isLoading
                                  ? Icons.pending
                                  : Icons.play_circle_fill_rounded,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.isLoading
                                    ? "Loading..."
                                    : "Watch Trailer",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: widget.isLoading
                                          ? Colors.white.withAlpha(150)
                                          : Colors.white,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).redacted(
                      context: context,
                      redact: widget.isLoading,
                      configuration: RedactedConfiguration(
                        animationDuration: Duration(milliseconds: 800),
                      ),
                    ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedIconButton extends StatelessWidget {
  const _AnimatedIconButton({
    required this.isActive,
    required this.controller,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.onPressed,
    required this.tooltip,
    this.isDisabled = false,
  });

  final IconData activeIcon;
  final AnimationController controller;
  final IconData inactiveIcon;
  final bool isActive;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (controller.value * 0.1),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withAlpha(102),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  customBorder: const CircleBorder(),
                  splashColor: Theme.of(context).primaryColor.withAlpha(77),
                  highlightColor: Theme.of(context).primaryColor.withAlpha(26),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : isDisabled
                          ? Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withAlpha(200)
                          : Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                        width: isActive ? 0 : 2,
                        color: isActive
                            ? Colors.transparent
                            : isDisabled
                            ? Theme.of(context).primaryColor.withAlpha(80)
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: RotationTransition(
                              turns: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isActive
                              ? activeIcon
                              : isDisabled
                              ? Icons.lock_clock_rounded
                              : inactiveIcon,
                          key: ValueKey(isActive),
                          size: 28,
                          color: isActive
                              ? Colors.white
                              : isDisabled
                              ? Colors.orange
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
