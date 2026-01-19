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
  final carouselItems = <Widget>[
    CarouselBannerWidget(title: "Avengers - EndGame", rating: "8.5"),
    CarouselBannerWidget(title: "Avengers - EndGame", rating: "8.5"),
    CarouselBannerWidget(title: "Avengers - EndGame", rating: "8.5"),
    CarouselBannerWidget(title: "Avengers - EndGame", rating: "8.5"),
    CarouselBannerWidget(title: "Avengers - EndGame", rating: "8.5"),
    CarouselBannerWidget(title: "Avengers - EndGame", rating: "8.5"),
    CarouselBannerWidget(title: "Avengers - EndGame", rating: "8.5"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        controller: ScrollController(),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SizedBox(height: 15),

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

                    SizedBox(height: 15),

                    FlutterCarousel(
                      items: carouselItems,
                      options: FlutterCarouselOptions(
                        controller: FlutterCarouselController(),
                        aspectRatio: 16 / 9,
                        autoPlay: true,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        autoPlayInterval: Duration(seconds: 3),
                        viewportFraction: 0.85,
                        floatingIndicator: false,
                        enlargeCenterPage: true,
                        slideIndicator: CircularWaveSlideIndicator(
                          slideIndicatorOptions: SlideIndicatorOptions(
                            indicatorBackgroundColor: carouselIndicatorColor,
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

                SizedBox(height: 20),

                HorizontalSliderWidget(title: "Popular Movies"),
                HorizontalSliderWidget(title: "Popular Tv"),
                HorizontalSliderWidget(title: "Top Rates Movies"),
                HorizontalSliderWidget(title: "Top Rated Tv"),
                HorizontalSliderWidget(title: "Upcoming Movies"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
