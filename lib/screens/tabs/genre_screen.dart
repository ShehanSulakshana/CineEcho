import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/custom_appbar.dart';
import 'package:cine_echo/widgets/grid_view.dart';

import 'package:flutter/material.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              //labelColor: navActive,
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
              // ignore: prefer
              tabs: [Text("Movies"), Text("Tv Series")],

              onTap: (value) {
                //TODO: Implement on tap API loading
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                //Movies Tab
                _MovieGenreTab(),

                //TvSeries Tab
                _TvGenreTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieGenreTab extends StatefulWidget {
  const _MovieGenreTab();

  @override
  State<_MovieGenreTab> createState() => _MovieGenreTabState();
}

class _MovieGenreTabState extends State<_MovieGenreTab> {
  late List<Map<String, dynamic>> genreList;
  int selectedGenreIndex = 0;
  bool _isLoading = true;
  late List<dynamic> resultList;

  final TmdbServices _tmdbServices = TmdbServices();

  Future<void> _loadData() async {
    try {
      final genre = genreList[selectedGenreIndex];
      resultList = await _tmdbServices.fetchGenreData('movie', genre['id']);

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
  void initState() {
    super.initState();
    genreList = [
      {'id': 28, 'name': 'Action'},
      {'id': 12, 'name': 'Adventure'},
      {'id': 16, 'name': 'Animation'},
      {'id': 35, 'name': 'Comedy'},
      {'id': 80, 'name': 'Crime'},
      {'id': 99, 'name': 'Documentary'},
      {'id': 18, 'name': 'Drama'},
      {'id': 10751, 'name': 'Family'},
      {'id': 14, 'name': 'Fantasy'},
      {'id': 36, 'name': 'History'},
      {'id': 27, 'name': 'Horror'},
      {'id': 10402, 'name': 'Music'},
      {'id': 9648, 'name': 'Mystery'},
      {'id': 10749, 'name': 'Romance'},
      {'id': 878, 'name': 'Science Fiction'},
      {'id': 10770, 'name': 'TV Movie'},
      {'id': 53, 'name': 'Thriller'},
      {'id': 10752, 'name': 'War'},
      {'id': 37, 'name': 'Western'},
    ];

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
            itemCount: genreList.length,
            padding: EdgeInsets.only(left: 8),

            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> genre = genreList[index];
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
                      _loadData();
                    });
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridViewWidget(dataList: resultList),
        ),
      ],
    );
  }
}

class _TvGenreTab extends StatefulWidget {
  const _TvGenreTab();

  @override
  State<_TvGenreTab> createState() => _TvGenreTabState();
}

class _TvGenreTabState extends State<_TvGenreTab> {
  late List<Map<String, dynamic>> genreList;
  int selectedGenreIndex = 0;
  bool _isLoading = true;
  late List<dynamic> resultList;

  final TmdbServices _tmdbServices = TmdbServices();

  Future<void> _loadData() async {
    try {
      final genre = genreList[selectedGenreIndex];
      resultList = await _tmdbServices.fetchGenreData('tv', genre['id']);

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
  void initState() {
    super.initState();
    genreList = [
      {'id': 10759, 'name': 'Action & Adventure'},
      {'id': 16, 'name': 'Animation'},
      {'id': 35, 'name': 'Comedy'},
      {'id': 80, 'name': 'Crime'},
      {'id': 99, 'name': 'Documentary'},
      {'id': 18, 'name': 'Drama'},
      {'id': 10751, 'name': 'Family'},
      {'id': 10762, 'name': 'Kids'},
      {'id': 37, 'name': 'Western'},
      {'id': 10763, 'name': 'News'},
      {'id': 10764, 'name': 'Reality'},
      {'id': 10765, 'name': 'Sci-Fi & Fantasy'},
      {'id': 10766, 'name': 'Soap'},
      {'id': 10767, 'name': 'Talk'},
      {'id': 10768, 'name': 'War & Politics'},
    ];

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
            itemCount: genreList.length,
            padding: EdgeInsets.only(left: 8),

            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> genre = genreList[index];
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
                      _loadData();
                    });
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridViewWidget(dataList: resultList),
        ),
      ],
    );
  }
}
