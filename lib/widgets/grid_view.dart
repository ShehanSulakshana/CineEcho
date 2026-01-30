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
          GridView.builder(
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2 / 3,
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
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
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
                ),
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
