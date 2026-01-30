import 'package:cine_echo/models/watch_history_repository.dart';
import 'package:cine_echo/screens/profile_tabs/favorites_tab.dart';
import 'package:cine_echo/screens/profile_tabs/watched_tab.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/completed_stat_card.dart';
import 'package:flutter/material.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  late ScrollController _scrollController;
  final WatchHistoryRepository _watchRepo = WatchHistoryRepository();

  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _statsFuture = _loadStats();
    _tabController?.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {
        _statsFuture = _loadStats();
      });
    }
  }

  void _refreshStats() {
    if (mounted) {
      setState(() {
        _statsFuture = _loadStats();
      });
    }
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final stats = await _watchRepo.getWatchStats();

    // Calculate watch time: 2 hours per movie + 45 mins per episode
    int totalMinutes =
        (stats.moviesWatchedCount * 120) + (stats.episodesWatchedCount * 45);
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    String watchTimeString = '${hours}h ${minutes}m';

    return {
      'watchTime': watchTimeString,
      'movies': stats.moviesWatchedCount,
      'episodes': stats.episodesWatchedCount,
    };
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _scrollController,
        builder: (context, child) {
          double scrollOffset = _scrollController.hasClients
              ? _scrollController.offset
              : 0;
          double scrollProgress = (scrollOffset / 390).clamp(0.0, 1.0);

          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 290,
                      floating: false,
                      pinned: false,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    15,
                                    12,
                                    15,
                                    0,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Row(
                                      children: [
                                        const Spacer(),
                                        Expanded(
                                          child: Text(
                                            "Profile",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(
                                              context,
                                            ).appBarTheme.titleTextStyle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              Icons.edit_note_rounded,
                                              size: 24,
                                              color: navActive,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25),

                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor.withAlpha(150),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 60,
                                          backgroundImage: AssetImage(
                                            'assets/splash/logo.png',
                                          ),
                                          backgroundColor: navNonActive,
                                        ),
                                      ),
                                      SizedBox(height: 18),
                                      SizedBox(
                                        width: 280,
                                        child: Text(
                                          "Shehan SS",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      SizedBox(
                                        width: 280,
                                        child: Text(
                                          "Movie & Series Enthusiast",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white70,
                                                fontSize: 12,
                                                letterSpacing: 0.3,
                                                fontStyle: FontStyle.italic,
                                                height: 1.4,
                                              ),
                                          softWrap: true,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 900),
                        curve: Curves.easeOutQuad,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 15 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _statsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final data = snapshot.data!;
                                return completedStatsCard(
                                  data['watchTime'] as String,
                                  data['movies'] as int,
                                  data['episodes'] as int,
                                );
                              }
                              return completedStatsCard('0h 0m', 0, 0);
                            },
                          ),
                        ),
                      ),
                    ),
                  ];
                },
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.easeOutQuad,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromARGB(255, 10, 40, 60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      height: 52,
                      child: TabBar(
                        controller: _tabController,
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        unselectedLabelStyle: TextStyle(
                          color: navNonActive,
                          fontSize: 17,
                          height: 1.5,
                        ),
                        dividerColor: Colors.transparent,
                        indicatorAnimation: TabIndicatorAnimation.linear,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tabs: [
                          Icon(Icons.favorite_border_rounded, size: 24),
                          Icon(Icons.check_circle_outlined, size: 24),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        FavoritesTab(onDataChanged: _refreshStats),
                        WatchedTab(onDataChanged: _refreshStats),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
