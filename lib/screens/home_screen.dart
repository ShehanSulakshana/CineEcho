import 'dart:ui';

import 'package:cine_echo/screens/tabs/discover_screen.dart';
import 'package:cine_echo/screens/tabs/feed_screen.dart';
import 'package:cine_echo/screens/tabs/genre_screen.dart';
import 'package:cine_echo/screens/tabs/personal_screen.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[
      Icons.home_outlined,
      Icons.explore_outlined,
      Icons.local_fire_department_outlined,
      Icons.person_outline,
    ];

    final pages = <Widget>[
      DiscoverScreen(),
      GenreScreen(),
      FeedScreen(),
      PersonalScreen(),
    ];

    final List<IconData> activeIcons = [
      Icons.home,
      Icons.explore,
      Icons.local_fire_department,
      Icons.person_rounded,
    ];

    final List<String> navText = ["Home", "Genre", "Feed", "Profile"];

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                IndexedStack(
                  index: navigationProvider.currentPage,
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
                                      transform: Matrix4.translationValues(
                                        isActive ? 0 : 0,
                                        0,
                                        0,
                                      )..scale(scaleValue),
                                      child: Icon(
                                        isActive
                                            ? activeIcons[index]
                                            : icons[index],
                                        size: 27,
                                        color: isActive
                                            ? navActive
                                            : navNonActive,
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
