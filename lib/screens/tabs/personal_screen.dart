import 'package:cine_echo/screens/profile_tabs/TestItem.dart';
import 'package:cine_echo/screens/tabs/genre_screen.dart';
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
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
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
                                // Header
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
                                        Expanded(child: Spacer()),
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
                                            alignment:
                                                AlignmentGeometry.centerRight,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.edit_note_rounded,
                                                size: 24,
                                                color: navActive,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25),

                                // Profile
                                Opacity(
                                  opacity: 1 - scrollProgress,
                                  child: TweenAnimationBuilder<double>(
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Stats Card
                    SliverToBoxAdapter(
                      child: Opacity(
                        opacity: 1 - scrollProgress,
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
                            child: completedStatsCard('10h 20m', 125, 25),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  // Tabs
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
                          Icon(Icons.photo_filter_rounded, size: 24),
                          Icon(Icons.favorite_border_rounded, size: 24),
                          Icon(Icons.check_circle_outlined, size: 24),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Testitem(itemno: 1),
                        Testitem(itemno: 2),
                        Testitem(itemno: 3),
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
