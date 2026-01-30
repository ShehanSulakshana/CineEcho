import 'package:cine_echo/screens/specific/details_screen.dart';
import 'package:cine_echo/providers/tmdb_provider.dart';
import 'package:cine_echo/providers/error_handler.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/carousel_banner.dart';
import 'package:cine_echo/widgets/custom_appbar.dart';
import 'package:cine_echo/widgets/horizontal_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tmdbProvider = Provider.of<TmdbProvider>(context, listen: false);
      if (tmdbProvider.isDiscoverLoading) {
        try {
          await tmdbProvider.loadDiscoverData();
        } catch (e) {
          if (mounted) {
            ErrorHandler.handleError(
              context,
              e,
              'Failed to load discover data',
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Consumer<TmdbProvider>(
        builder: (context, tmdbProvider, _) {
          if (tmdbProvider.isDiscoverLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    if (tmdbProvider.trending.isNotEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FlutterCarousel.builder(
                            itemCount: tmdbProvider.trending.length > 10
                                ? 10
                                : tmdbProvider.trending.length,
                            itemBuilder: (context, index, currentIndex) {
                              final item = tmdbProvider.trending[index];
                              final id = item['id'];
                              final title =
                                  item['title'] ?? item['name'] ?? 'Unknown';
                              final rating = (item['vote_average'] ?? 0.0)
                                  .toStringAsFixed(1);
                              final releaseDate =
                                  item['first_air_date'] ??
                                  item['release_date'] ??
                                  '2000-01-01';
                              final releaseYear = DateTime.parse(releaseDate);
                              final imagePath = item['backdrop_path'];
                              final type = item['media_type'] ?? 'movie';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        dataMap: item,
                                        typeData: type,
                                        id: id.toString(),
                                        heroSource: 'carousel',
                                      ),
                                    ),
                                  );
                                },
                                child: CarouselBannerWidget(
                                  title: title,
                                  rating: rating,
                                  releaseYear: releaseYear.year.toString(),
                                  imageLink:
                                      "https://image.tmdb.org/t/p/w780$imagePath",
                                ),
                              );
                            },
                            options: FlutterCarouselOptions(
                              controller: FlutterCarouselController(),
                              aspectRatio: 16 / 9,
                              autoPlay: true,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              autoPlayInterval: const Duration(seconds: 3),
                              viewportFraction: 0.85,
                              floatingIndicator: false,
                              enlargeCenterPage: true,
                              slideIndicator: CircularWaveSlideIndicator(
                                slideIndicatorOptions: SlideIndicatorOptions(
                                  indicatorBackgroundColor:
                                      carouselIndicatorColor,
                                  currentIndicatorColor: blueColor,
                                  indicatorRadius: 3.5,
                                  itemSpacing: 10,
                                ),
                              ),
                              enableInfiniteScroll: true,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    HorizontalSliderWidget(
                      title: "Popular Movies",
                      endpoint: '/movie/popular',
                      dataList: tmdbProvider.popularMovie,
                      totalPages: tmdbProvider.popularMovieTotalPages,
                    ),
                    HorizontalSliderWidget(
                      title: "Popular Tv",
                      endpoint: '/tv/popular',
                      dataList: tmdbProvider.popularTv,
                      totalPages: tmdbProvider.popularTvTotalPages,
                    ),
                    HorizontalSliderWidget(
                      title: "Top Rated Movies",
                      endpoint: '/movie/top_rated',
                      dataList: tmdbProvider.topRatedMovie,
                      totalPages: tmdbProvider.topRatedMovieTotalPages,
                    ),
                    HorizontalSliderWidget(
                      title: "Top Rated Tv",
                      endpoint: '/tv/top_rated',
                      dataList: tmdbProvider.topRatedTv,
                      totalPages: tmdbProvider.topRatedTvTotalPages,
                    ),
                    HorizontalSliderWidget(
                      title: "Upcoming Movies",
                      endpoint: '/movie/upcoming',
                      dataList: tmdbProvider.upcomingMovies,
                      totalPages: tmdbProvider.upcomingMoviesTotalPages,
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
