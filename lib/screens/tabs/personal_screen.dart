import 'dart:async';
import 'package:cine_echo/models/watch_history_repository.dart';
import 'package:cine_echo/screens/profile_editor_screen.dart';
import 'package:cine_echo/screens/profile_tabs/favorites_tab.dart';
import 'package:cine_echo/screens/profile_tabs/watched_tab.dart';
import 'package:cine_echo/screens/feedback_screen.dart';
import 'package:cine_echo/screens/about_screen.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/completed_stat_card.dart';
import 'package:cine_echo/providers/auth_provider.dart' as auth_provider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController;
  late ScrollController _scrollController;
  final WatchHistoryRepository _watchRepo = WatchHistoryRepository();

  late Future<Map<String, dynamic>> _statsFuture;
  Future<Map<String, dynamic>?>? _profileFuture;
  int _statsUpdateKey = 0; // Key to force FutureBuilder rebuild
  late Timer? _statsRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _statsFuture = _loadStats();
    _profileFuture = _loadProfile();
    _tabController?.addListener(_onTabChanged);

    // Listen to visibility changes to refresh stats when returning to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupStatsRefreshListener();
    });
  }

  void _setupStatsRefreshListener() {
    // Refresh stats every time the personal screen is visible
    if (mounted) {
      _refreshStats();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshStats();
    }
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
      // Increment the key to force FutureBuilder to rebuild
      setState(() {
        _statsUpdateKey++;
        _statsFuture = _loadStats();
      });

      // Set up periodic refresh while user is on this screen
      _statsRefreshTimer?.cancel();
      _statsRefreshTimer = Timer.periodic(Duration(seconds: 2), (_) {
        if (mounted && _tabController?.index == 0) {
          // Only refresh when on profile tab
          setState(() {
            _statsUpdateKey++;
            _statsFuture = _loadStats();
          });
        }
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

  Future<Map<String, dynamic>?> _loadProfile() async {
    final authProvider = Provider.of<auth_provider.AuthenticationProvider>(
      context,
      listen: false,
    );
    final user = authProvider.currentUser;
    if (user == null) return null;
    return authProvider.fetchUserProfile(user.uid);
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _scrollController.dispose();
    _tabController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _statsRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshStats();
          // Add a slight delay for visual feedback
          await Future.delayed(Duration(milliseconds: 800));
        },
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.black87,
        child: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            return NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            _refreshStats();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Refreshing...'),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.refresh_rounded,
                                              size: 24,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
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
                                          child: PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileEditorScreen(),
                                                  ),
                                                );
                                              } else if (value == 'feedback') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FeedbackScreen(),
                                                  ),
                                                );
                                              } else if (value == 'about') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AboutScreen(),
                                                  ),
                                                );
                                              }
                                            },
                                            color: const Color.fromARGB(
                                              255,
                                              20,
                                              40,
                                              55,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 8,
                                            itemBuilder:
                                                (
                                                  BuildContext context,
                                                ) => <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.edit_rounded,
                                                          color: navActive,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          'Edit Profile',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'feedback',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .feedback_rounded,
                                                          color: navActive,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          'Send Feedback',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'about',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.info_rounded,
                                                          color: navActive,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          'About',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Icon(
                                                    Icons.more_vert_rounded,
                                                    size: 24,
                                                    color: navActive,
                                                  ),
                                                ),
                                              ),
                                            ),
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
                                child: FutureBuilder<Map<String, dynamic>?>(
                                  future: _profileFuture,
                                  builder: (context, snapshot) {
                                    final authProvider =
                                        Provider.of<
                                          auth_provider.AuthenticationProvider
                                        >(context, listen: false);
                                    final user = authProvider.currentUser;
                                    final profile = snapshot.data;

                                    final displayName =
                                        (profile?['displayName'] as String?)
                                                ?.trim()
                                                .isNotEmpty ==
                                            true
                                        ? profile!['displayName'] as String
                                        : (user?.displayName ?? 'User');

                                    final about =
                                        (profile?['about'] as String?)
                                                ?.trim()
                                                .isNotEmpty ==
                                            true
                                        ? profile!['about'] as String
                                        : 'No bio added yet.';

                                    final photoUrl =
                                        (profile?['photoUrl'] as String?)
                                                ?.trim()
                                                .isNotEmpty ==
                                            true
                                        ? profile!['photoUrl'] as String
                                        : user?.photoURL;

                                    return Column(
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
                                            backgroundColor: navNonActive,
                                            backgroundImage: photoUrl != null
                                                ? NetworkImage(photoUrl)
                                                : null,
                                            child: photoUrl == null
                                                ? Icon(
                                                    Icons.person_rounded,
                                                    size: 64,
                                                    color: Colors.white70,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        SizedBox(height: 18),
                                        SizedBox(
                                          width: 280,
                                          child: Text(
                                            displayName,
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
                                            about,
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
                                    );
                                  },
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
                          key: ValueKey(_statsUpdateKey),
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
                              color: Colors.black.withAlpha(38),
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
      ),
    );
  }
}
