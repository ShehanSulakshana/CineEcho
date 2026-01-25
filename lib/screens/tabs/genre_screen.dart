import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/custom_appbar.dart';
import 'package:cine_echo/widgets/grid_view.dart';
import 'package:cine_echo/models/genre_list.dart';

import 'package:flutter/material.dart';

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
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isRequestInFlight = false;
  late List<dynamic> resultList;
  int _currentPage = 1;
  int _totalPages = 1;

  final TmdbServices _tmdbServices = TmdbServices();

  Future<void> _loadData({bool loadMore = false}) async {
    if (_isRequestInFlight) return; // prevent overlapping calls
    try {
      _isRequestInFlight = true;
      if (!loadMore) {
        _currentPage = 1;
      }

      final genre = widget.genreList[selectedGenreIndex];
      final data = await _tmdbServices.fetchGenreDataPaginated(
        widget.type,
        genre['id'],
        page: _currentPage,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            resultList.addAll(data['results']);
            _isLoadingMore = false;
          } else {
            resultList = data['results'];
            _isLoading = false;
          }
          _totalPages = data['total_pages'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } finally {
      _isRequestInFlight = false;
    }
  }

  Future<void> _onRefresh() async {
    _isLoadingMore = false;
    await _loadData(loadMore: false);
  }

  void _loadMoreData() {
    if (_currentPage < _totalPages && !_isLoadingMore && !_isRequestInFlight) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _loadData(loadMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    resultList = [];
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
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
                      _isLoading = true;
                    });
                    _loadData();
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: GridViewWidget(
                    dataList: resultList,
                    onLoadMore: _loadMoreData,
                    isLoadingMore: _isLoadingMore,
                    hasMorePages: _currentPage < _totalPages,
                    typeData: widget.type,
                  ),
                ),
        ),
      ],
    );
  }
}
