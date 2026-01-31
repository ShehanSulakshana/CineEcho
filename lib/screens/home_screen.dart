import 'dart:ui';

import 'package:cine_echo/screens/tabs/discover_screen.dart';
import 'package:cine_echo/screens/tabs/movies_screen.dart';
import 'package:cine_echo/screens/tabs/tv_series_screen.dart';
import 'package:cine_echo/screens/tabs/personal_screen.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heroicons/heroicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final icons = <dynamic>[
    Icons.home_outlined,
    Icons.movie_outlined,
    HeroIcons.tv,
    Icons.person_outline,
  ];

  final pages = <Widget>[
    DiscoverScreen(),
    MoviesScreen(),
    TvSeriesScreen(),
    PersonalScreen(),
  ];

  final List<dynamic> activeIcons = [
    Icons.home,
    Icons.movie,
    HeroIcons.tv,
    Icons.person_rounded,
  ];

  final List<String> navText = ["Home", "Movies", "Series", "Profile"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    navigationProvider.setCurrentPage(_tabController.index);
  }

  Widget _buildIcon(dynamic iconData, bool isActive) {
    if (iconData == HeroIcons.tv) {
      return HeroIcon(
        iconData as HeroIcons,
        style: isActive ? HeroIconStyle.solid : HeroIconStyle.outline,
        color: isActive ? navActive : navNonActive,
        size: 27,
      );
    }
    return Icon(iconData, size: 27, color: isActive ? navActive : navNonActive);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) {
        // Update tab index when navigation provider changes
        if (_tabController.index != navigationProvider.currentPage) {
          _tabController.animateTo(navigationProvider.currentPage);
        }

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: pages,
                ),
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 90,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadiusGeometry.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          color: Theme.of(context).primaryColor.withAlpha(30),
                          height: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(icons.length, (index) {
                              final isActive =
                                  navigationProvider.currentPage == index;
                              final scaleValue = isActive ? 1.1 : 1.0;
                              return GestureDetector(
                                onTap: () {
                                  navigationProvider.setCurrentPage(index);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration: Duration(microseconds: 400),
                                      curve: Curves.easeInOut,
                                      transform: Matrix4.diagonal3Values(
                                        scaleValue,
                                        scaleValue,
                                        1,
                                      ),
                                      child: _buildIcon(
                                        isActive
                                            ? activeIcons[index]
                                            : icons[index],
                                        isActive,
                                      ),
                                    ),

                                    SizedBox(height: 2),
                                    Text(
                                      navText[index],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isActive
                                                ? navActive
                                                : navNonActive,
                                            fontSize: 12,
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
