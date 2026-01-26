import 'dart:ui';

import 'package:cine_echo/models/genre_list.dart';
import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/cast_horizontal_slider.dart';
import 'package:cine_echo/widgets/horizontal_slider.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.dataMap,
    required this.typeData,
  });

  final Map<String, dynamic> dataMap;
  final String typeData;

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

  String getType(String typeData) {
    final String type;
    if (typeData.contains('movie')) {
      type = 'movie';
    } else {
      type = 'tv';
    }
    return type;
  }

  final TmdbServices _tmdbServices = TmdbServices();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    moreDetailsMap = await _tmdbServices.fetchDetails(
      widget.dataMap['id'].toString(),
      getType(widget.typeData),
    );

    if (getType(widget.typeData) == 'movie') {
      final int minutes =
          int.tryParse(moreDetailsMap['runtime']?.toString() ?? '0') ?? 0;
      final int hours = minutes ~/ 60;
      final int mins = minutes % 60;
      runtime = '0${hours}h ${mins}m';
    }

    cast = moreDetailsMap['credits']['cast'];
    recommendations = moreDetailsMap['recommendations']['results'];
    totalRecommendationPages =
        moreDetailsMap['recommendations']['total_pages'] ?? 1;

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
    final releaseYear = DateTime.parse(
      widget.dataMap['first_air_date'] ?? widget.dataMap['release_date'],
    ).year.toString();
    final bannerPath = widget.dataMap['backdrop_path'];
    final posterPath = widget.dataMap['poster_path'];
    final bannerLink = "https://image.tmdb.org/t/p/w780/$bannerPath";
    final posterLink = "https://image.tmdb.org/t/p/w342/$posterPath";
    final overview =
        widget.dataMap['overview'] ?? 'Overview not available for this.';

    final Map<int, dynamic> allGenreMap = GenreListClass.getGenreMap();

    String getGenre() {
      var buffer = StringBuffer();
      final List<dynamic> genreIdList = widget.dataMap['genre_ids'];
      for (var i = 0; i < genreIdList.length; i++) {
        final genreId = genreIdList[i];
        final genreName = allGenreMap[genreId];
        if (i != genreIdList.length - 1) {
          buffer.write("$genreName, ");
        } else {
          buffer.write("$genreName");
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
                              )
                            : FadeInImage(
                                image: NetworkImage(bannerLink),
                                placeholder: const AssetImage(
                                  'assets/splash/logo.png',
                                ),
                                fit: BoxFit.cover,
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
                                style: ButtonStyle(
                                  // backgroundColor: WidgetStatePropertyAll(
                                  //   Theme.of(
                                  //     context,
                                  //   ).scaffoldBackgroundColor.withAlpha(50),
                                  // ),
                                ),
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

                  //poster + details
                  Column(
                    children: [
                      SizedBox(height: bgHeight - overlap),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 180,
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(20),
                                child: AspectRatio(
                                  aspectRatio: 2 / 3,
                                  child: posterLink.isEmpty
                                      ? Image.asset(
                                          'assets/splash/logo.png',
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage(
                                          image: NetworkImage(posterLink),
                                          placeholder: const AssetImage(
                                            'assets/splash/logo.png',
                                          ),
                                          fit: BoxFit.cover,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: title.length > 15
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
                                              accelerationCurve: Curves.linear,
                                              decelerationDuration:
                                                  const Duration(
                                                    milliseconds: 500,
                                                  ),
                                              decelerationCurve: Curves.easeOut,
                                            )
                                          : Text(
                                              title,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                            ),
                                    ),
                                    //SizedBox(height: 5),
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
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 15,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            rating,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
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
                                    ),

                                    SizedBox(height: 3),
                                    Text(
                                      getGenre(),
                                      style: TextStyle(fontSize: 13),
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
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Buttons(
                              trailerKey: trailerKey,
                              isLoading: _isLoading,
                            ),

                            SizedBox(height: 30),
                            Text(
                              "Overview",
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 5),
                            Text(
                              overview,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),

                      _isLoading
                          ? SizedBox()
                          : CastHorizontalSlider(castList: cast),

                      //recommendations slider
                      SizedBox(height: 30),

                      _isLoading && recommendations.isEmpty
                          ? SizedBox()
                          : HorizontalSliderWidget(
                              title: "Recommendations",
                              endpoint: "movie",
                              dataList: recommendations,
                              totalPages: totalRecommendationPages,
                            ),
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
  const Buttons({super.key, required this.trailerKey, required this.isLoading});

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> with TickerProviderStateMixin {
  late bool isFavorite;
  late bool markeAsWatched; //TODO : Implement marked as watchd & is favorite

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
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      _favoriteController.forward();
    } else {
      _favoriteController.reverse();
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).primaryColor.withAlpha(230),
        content: Row(
          children: [
            Icon(
              isFavorite ? Icons.favorite_rounded : Icons.heart_broken_rounded,
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
        // action: SnackBarAction(
        //   label: "UNDO",
        //   textColor: Colors.white,
        //   onPressed: _toggleFavorite,
        // ),
      ),
    );
  }

  void _toggleWatched() {
    setState(() {
      markeAsWatched = !markeAsWatched;
    });

    if (markeAsWatched) {
      _watchedController.forward();
    } else {
      _watchedController.reverse();
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).primaryColor.withAlpha(230),
        content: Row(
          children: [
            Icon(
              markeAsWatched ? Icons.check_circle : Icons.remove_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                markeAsWatched
                    ? "Marked as watched"
                    : "Removed from watched list",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        // action: SnackBarAction(
        //   label: "UNDO",
        //   textColor: Colors.white,
        //   onPressed: _toggleWatched,
        // ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Favorite Button
          _AnimatedIconButton(
            isActive: isFavorite,
            controller: _favoriteController,
            activeIcon: Icons.favorite_rounded,
            inactiveIcon: Icons.favorite_border_rounded,
            onPressed: _toggleFavorite,
            tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
          ),

          const SizedBox(width: 12),

          // Watched Button
          _AnimatedIconButton(
            isActive: markeAsWatched,
            controller: _watchedController,
            activeIcon: Icons.done_all_rounded,
            inactiveIcon: Icons.done_rounded,
            onPressed: _toggleWatched,
            tooltip: markeAsWatched ? "Mark as unwatched" : "Mark as watched",
          ),

          const SizedBox(width: 12),

          // Watch Trailer Button
          Expanded(
            child: MouseRegion(
              onEnter: (_) => _trailerController.forward(),
              onExit: (_) => _trailerController.reverse(),
              child: AnimatedBuilder(
                animation: _trailerController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_trailerController.value * 0.02),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withAlpha(
                              (77 + (_trailerController.value * 51)).round(),
                            ),
                            blurRadius: 8 + (_trailerController.value * 4),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.pressed)) {
                              return 1.0;
                            }
                            return 3.0 + (_trailerController.value * 2);
                          }),
                          shadowColor: WidgetStatePropertyAll(
                            Theme.of(context).primaryColor.withAlpha(128),
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.pressed)) {
                              return Theme.of(
                                context,
                              ).primaryColor.withAlpha(204);
                            }
                            return Theme.of(context).primaryColor;
                          }),
                          foregroundColor: const WidgetStatePropertyAll(
                            Colors.white,
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
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                "Watch Trailer",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom animated icon button widget for better reusability
class _AnimatedIconButton extends StatelessWidget {
  const _AnimatedIconButton({
    required this.isActive,
    required this.controller,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData activeIcon;
  final AnimationController controller;
  final IconData inactiveIcon;
  final bool isActive;
  final VoidCallback onPressed;
  final String tooltip;

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
                          : Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                        width: isActive ? 0 : 2,
                        color: isActive
                            ? Colors.transparent
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
                          isActive ? activeIcon : inactiveIcon,
                          key: ValueKey(isActive),
                          size: 28,
                          color: isActive
                              ? Colors.white
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
