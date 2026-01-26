import 'package:cine_echo/screens/specific/details_screen.dart';
import 'package:cine_echo/screens/specific/seemore_screen.dart';
import 'package:flutter/material.dart';

class HorizontalSliderWidget extends StatefulWidget {
  final String title;
  final List<dynamic> dataList;
  final String endpoint;
  final int totalPages;
  final bool showElements;
  final Duration fadeDuration;

  const HorizontalSliderWidget({
    super.key,
    required this.title,
    required this.endpoint,
    required this.dataList,
    required this.totalPages,
    this.showElements = true,
    this.fadeDuration = const Duration(milliseconds: 600),
  });

  @override
  State<HorizontalSliderWidget> createState() => _HorizontalSliderWidgetState();
}

class _HorizontalSliderWidgetState extends State<HorizontalSliderWidget> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _opacity = widget.showElements ? 1 : 0);
    });
  }

  @override
  void didUpdateWidget(covariant HorizontalSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showElements != widget.showElements) {
      setState(() => _opacity = widget.showElements ? 1 : 0);
    }
  }

  String getType({int indexOfItem = 0}) {
    if (widget.endpoint.contains('movie') || widget.endpoint.contains('tv')) {
      return widget.endpoint;
    }
    return widget.dataList[indexOfItem]['media_type'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.fadeDuration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          SizedBox(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeemoreScreen(
                          endpoint: getType(),
                          appbarTitle: widget.title,
                          initialData: widget.dataList,
                          initialTotalPages: widget.totalPages,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Scroll
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: widget.dataList.length > 20
                  ? 20
                  : widget.dataList.length,
              itemBuilder: (context, index) {
                final item = widget.dataList[index];
                final title = item['title'] ?? item['name'] ?? 'Unknown';
                final releaseYear = DateTime.parse(
                  item['first_air_date'] ?? item['release_date'],
                ).year.toString();
                final imagePath = item['poster_path'];
                final imageLink = "https://image.tmdb.org/t/p/w342$imagePath";

                bool imageLoadingError = false;
                if (imagePath == null) {
                  imageLoadingError = true;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            dataMap: widget.dataList[index],
                            typeData: getType(indexOfItem: index),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster (smaller)
                          Container(
                            width: 90,
                            height: 135,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageLink.isEmpty || imageLoadingError
                                  ? Image.asset(
                                      'assets/splash/logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : FadeInImage(
                                      image: NetworkImage(imageLink),
                                      placeholder: const AssetImage(
                                        'assets/splash/logo.png',
                                      ),
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: double.infinity,
                                    ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: 90,
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 2),

                          // Year + Rating (smaller)
                          Text(
                            releaseYear,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
