import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/carousel_banner.dart';
import 'package:cine_echo/widgets/custom_appbar.dart';
import 'package:cine_echo/widgets/horizontal_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:cine_echo/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late List<dynamic> trending;
  late List<dynamic> nowPlaying;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      trending = await fetchSectionData('/trending/all/day');
      //nowPlaying = await fetchSectionData('/movie/now_playing');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<dynamic>> fetchSectionData(String endpoint) async {
    final url =
        'https://api.themoviedb.org/3$endpoint?api_key=${Env.tmdbApiKey}';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    return data['results'];
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
                      const HorizontalSliderWidget(title: "Popular Movies"),
                      const HorizontalSliderWidget(title: "Popular Tv"),
                      const HorizontalSliderWidget(title: "Top Rates Movies"),
                      const HorizontalSliderWidget(title: "Top Rated Tv"),
                      const HorizontalSliderWidget(title: "Upcoming Movies"),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
