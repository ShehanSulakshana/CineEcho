import 'package:cine_echo/providers/tmdb_provider.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/custom_appbar.dart';
import 'package:cine_echo/widgets/grid_view.dart';
import 'package:cine_echo/models/genre_list.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  TabController? _tabController;

  late _GenreTab movieGenreTab;
  late _GenreTab tvGenreTab;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    movieGenreTab = _GenreTab(
      type: "movie",
      genreList: GenreListClass.getMovieGenreList(),
    );
    tvGenreTab = _GenreTab(
      type: "tv",
      genreList: GenreListClass.getTvGenreList(),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              controller: _tabController,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 17,
                height: 3,
              ),
              unselectedLabelStyle: TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 3,
              ),
              dividerColor: Theme.of(context).disabledColor,
              indicatorAnimation: TabIndicatorAnimation.elastic,
              tabs: [Text("Movies"), Text("Tv Series")],
              onTap: (value) {
                //TODO: Implement on tap API loading
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [movieGenreTab, tvGenreTab],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreTab extends StatefulWidget {
  final List<Map<String, dynamic>> genreList;
  final String type;
  const _GenreTab({required this.genreList, required this.type});

  @override
  State<_GenreTab> createState() => _GenreTabState();
}

class _GenreTabState extends State<_GenreTab> {
  int selectedGenreIndex = 0;
  bool _isRequestInFlight = false;

  Future<void> _loadData({bool loadMore = false}) async {
    if (_isRequestInFlight) return;

    try {
      _isRequestInFlight = true;
      final genre = widget.genreList[selectedGenreIndex];
      final tmdbProvider = Provider.of<TmdbProvider>(context, listen: false);
      final key = '${widget.type}_${genre['id']}';

      if (!loadMore) {
        tmdbProvider.resetGenreData(key);
      }

      await tmdbProvider.loadGenreData(
        widget.type,
        genre['id'],
        loadMore: loadMore,
      );
    } finally {
      _isRequestInFlight = false;
    }
  }

  Future<void> _onRefresh() async {
    await _loadData(loadMore: false);
  }

  void _loadMoreData() {
    final genre = widget.genreList[selectedGenreIndex];
    final tmdbProvider = Provider.of<TmdbProvider>(context, listen: false);
    final key = '${widget.type}_${genre['id']}';

    if (!_isRequestInFlight &&
        !tmdbProvider.isGenreLoadingMore(key) &&
        tmdbProvider.getGenreCurrentPage(key) <
            tmdbProvider.getGenreTotalPages(key)) {
      _loadData(loadMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final genre = widget.genreList[selectedGenreIndex];
    final key = '${widget.type}_${genre['id']}';

    return Consumer<TmdbProvider>(
      builder: (context, tmdbProvider, _) {
        final resultList = tmdbProvider.getGenreData(key);
        final isLoading = tmdbProvider.isGenreLoading(key);
        final isLoadingMore = tmdbProvider.isGenreLoadingMore(key);
        final currentPage = tmdbProvider.getGenreCurrentPage(key);
        final totalPages = tmdbProvider.getGenreTotalPages(key);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(top: 8),
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.genreList.length,
                padding: EdgeInsets.only(left: 8),
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> genre = widget.genreList[index];
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
                        typeData: widget.type,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
