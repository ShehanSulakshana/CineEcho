import 'dart:math' as math;

import 'package:cine_echo/screens/specific/details_screen.dart';
import 'package:cine_echo/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';

class GridViewWidget extends StatefulWidget {
  final List<dynamic> dataList;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool hasMorePages;
  final String typeData;
  final Duration fadeDuration; // add

  const GridViewWidget({
    super.key,
    required this.dataList,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.hasMorePages,
    required this.typeData,
    this.fadeDuration = const Duration(milliseconds: 600), // add
  });

  @override
  State<GridViewWidget> createState() => _GridViewWidgetState();
}

class _GridViewWidgetState extends State<GridViewWidget> {
  late ScrollController _scrollController;
  double _opacity = 0; // add

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // trigger fade-in after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _opacity = 1);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (widget.hasMorePages && !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }
  }

  String _extractYear(dynamic dateString) {
    try {
      if (dateString == null || dateString.toString().isEmpty) {
        return 'Unknown';
      }
      final parsedDate = DateTime.parse(dateString.toString());
      return parsedDate.year.toString();
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.fadeDuration,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const minItemWidth = 120.0;
              const crossAxisSpacing = 12.0;
              final crossAxisCount = math.max(
                3,
                (constraints.maxWidth / minItemWidth).floor(),
              );
              final totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
              final itemWidth =
                  (constraints.maxWidth - totalSpacing) / crossAxisCount;
              final itemHeight = itemWidth * 1.5;
              const itemTextHeight = 44.0;
              final tileHeight = itemHeight + itemTextHeight;
              final tileAspectRatio = itemWidth / tileHeight;

              return GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: tileAspectRatio,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: 12,
                ),
                itemCount: widget.dataList.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 20, bottom: 100),
                itemBuilder: (BuildContext context, int index) {
                  final item = widget.dataList[index];
                  final id = item['id'];
                  final title = item['title'] ?? item['name'] ?? 'Unknown';
                  final releaseYear = _extractYear(
                    item['first_air_date'] ?? item['release_date'],
                  );
                  final imagePath = item['poster_path'];
                  final imageLink = "https://image.tmdb.org/t/p/w342$imagePath";

                  bool imageLoadingError = false;
                  if (imagePath == null) {
                    imageLoadingError = true;
                  }
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              dataMap: item,
                              typeData: widget.typeData,
                              id: id.toString(),
                              heroSource: 'gridview',
                              unique: widget.typeData,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Poster (responsive)
                            Container(
                              width: itemWidth,
                              height: itemHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(77),
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: Hero(
                                tag: "gridview_poster_${id}_${widget.typeData}",
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: imageLink.isEmpty || imageLoadingError
                                      ? Image.asset(
                                          'assets/splash/logo.png',
                                          fit: BoxFit.cover,
                                        )
                                      : SafeNetworkImage(
                                          imageUrl: imageLink,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          placeholder: Image.asset(
                                            'assets/splash/logo.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: itemWidth,
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
                                  ?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (widget.isLoadingMore)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
