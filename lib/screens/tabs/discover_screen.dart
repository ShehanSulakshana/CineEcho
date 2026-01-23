import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/carousel_banner.dart';
import 'package:cine_echo/widgets/custom_appbar.dart';
import 'package:cine_echo/widgets/horizontal_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late List<dynamic> trending;
  late List<dynamic> popularMovie;
  late List<dynamic> popularTv;
  late List<dynamic> topRatedMovie;
  late List<dynamic> topRatedTv;
  late List<dynamic> upcomingMovies;

  bool _isLoading = true;
  final TmdbServices _tmdbServices = TmdbServices();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      trending =
          (await _tmdbServices.fetchSectionData(
            '/trending/all/day',
          ))['results'] ??
          [];
      popularMovie =
          (await _tmdbServices.fetchSectionData('/movie/popular'))['results'] ??
          [];
      popularTv =
          (await _tmdbServices.fetchSectionData('/tv/popular'))['results'] ??
          [];
      topRatedMovie =
          (await _tmdbServices.fetchSectionData(
            '/movie/top_rated',
          ))['results'] ??
          [];
      topRatedTv =
          (await _tmdbServices.fetchSectionData('/tv/top_rated'))['results'] ??
          [];
      upcomingMovies =
          (await _tmdbServices.fetchSectionData(
            '/movie/upcoming',
          ))['results'] ??
          [];

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remove _loadData() call from here - it should only be in initState()

    return Scaffold(
      appBar: CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Trending",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 15),
                          FlutterCarousel.builder(
                            itemCount: 10,
                            itemBuilder: (context, index, currentIndex) {
                              final item = trending[index];
                              final title =
                                  item['title'] ?? item['name'] ?? 'Unknown';
                              final rating = (item['vote_average'] ?? 0.0)
                                  .toStringAsFixed(1);
                              final releaseYear = DateTime.parse(
                                item['first_air_date'] ?? item['release_date'],
                              );
                              final imagePath = item['backdrop_path'];
                              //TODO : Handle net image null error
                              return CarouselBannerWidget(
                                title: title,
                                rating: rating,
                                releaseYear: releaseYear.year.toString(),
                                imageLink:
                                    "https://image.tmdb.org/t/p/w400$imagePath",
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
                        endpoint: '/trending/all/day',
                        dataList: popularMovie,
                      ),
                      HorizontalSliderWidget(
                        title: "Popular Tv",
                        endpoint: '/tv/popular',
                        dataList: popularTv,
                      ),
                      HorizontalSliderWidget(
                        title: "Top Rated Movies",
                        endpoint: '/movie/top_rated',
                        dataList: topRatedMovie,
                      ),
                      HorizontalSliderWidget(
                        title: "Top Rated Tv",
                        endpoint: '/tv/top_rated',
                        dataList: topRatedTv,
                      ),
                      HorizontalSliderWidget(
                        title: "Upcoming Movies",
                        endpoint: '/movie/upcoming',
                        dataList: upcomingMovies,
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
