import 'package:cine_echo/providers/tmdb_provider.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/grid_view.dart';
import 'package:cine_echo/models/genre_list.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedGenreIndex = 0;
  bool _isRequestInFlight = false;

  @override
  bool get wantKeepAlive => true;

  late List<Map<String, dynamic>> movieGenreList;

  @override
  void initState() {
    super.initState();
    movieGenreList = GenreListClass.getMovieGenreList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData({bool loadMore = false}) async {
    if (_isRequestInFlight) return;
    if (selectedGenreIndex < 0 || selectedGenreIndex >= movieGenreList.length) {
      return;
    }

    try {
      _isRequestInFlight = true;
      final genre = movieGenreList[selectedGenreIndex];
      final tmdbProvider = Provider.of<TmdbProvider>(context, listen: false);
      final key = 'movie_${genre['id']}';

      if (!loadMore) {
        tmdbProvider.resetGenreData(key);
      }

      await tmdbProvider.loadGenreData(
        'movie',
        genre['id'],
        loadMore: loadMore,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load movies. Please try again.')),
        );
      }
    } finally {
      _isRequestInFlight = false;
    }
  }

  Future<void> _onRefresh() async {
    await _loadData(loadMore: false);
  }

  void _loadMoreData() {
    if (selectedGenreIndex < 0 || selectedGenreIndex >= movieGenreList.length) {
      return;
    }
    final genre = movieGenreList[selectedGenreIndex];
    final tmdbProvider = Provider.of<TmdbProvider>(context, listen: false);
    final key = 'movie_${genre['id']}';

    if (!_isRequestInFlight &&
        !tmdbProvider.isGenreLoadingMore(key) &&
        tmdbProvider.getGenreCurrentPage(key) <
            tmdbProvider.getGenreTotalPages(key)) {
      _loadData(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Ensure selectedGenreIndex is within bounds
    if (selectedGenreIndex < 0 || selectedGenreIndex >= movieGenreList.length) {
      selectedGenreIndex = 0;
    }

    final genre = movieGenreList[selectedGenreIndex];
    final key = 'movie_${genre['id']}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text('Movies', style: Theme.of(context).appBarTheme.titleTextStyle),
          ],
        ),
      ),
      body: Consumer<TmdbProvider>(
        builder: (context, tmdbProvider, _) {
          final resultList = tmdbProvider.getGenreData(key);
          final isLoading = tmdbProvider.isGenreLoading(key);
          final isLoadingMore = tmdbProvider.isGenreLoadingMore(key);
          final currentPage = tmdbProvider.getGenreCurrentPage(key);
          final totalPages = tmdbProvider.getGenreTotalPages(key);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 8),
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movieGenreList.length,
                    padding: EdgeInsets.only(left: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> genre = movieGenreList[index];
                      return Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: GestureDetector(
                          child: Chip(
                            label: Text(genre['name']),
                            labelStyle: selectedGenreIndex == index
                                ? TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  )
                                : Theme.of(context).textTheme.bodySmall,
                            backgroundColor: selectedGenreIndex == index
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: ashColor),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedGenreIndex = index;
                            });
                            _loadData();
                          },
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: GridViewWidget(
                            dataList: resultList,
                            onLoadMore: _loadMoreData,
                            isLoadingMore: isLoadingMore,
                            hasMorePages: currentPage < totalPages,
                            typeData: 'movie',
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
