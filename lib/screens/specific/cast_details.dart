import 'dart:ui';

import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/horizontal_slider.dart';
import 'package:flutter/material.dart';
import 'package:redacted/redacted.dart';

class CastDetails extends StatefulWidget {
  final String actorId;
  final String imagePath;

  const CastDetails({
    super.key,
    required this.actorId,
    required this.imagePath,
  });

  @override
  State<CastDetails> createState() => _CastDetailsState();
}

class _CastDetailsState extends State<CastDetails> {
  String imageLink = '';
  late String actorName;
  late String biography;
  late Map dataMap;
  late List movieCredits = [];
  bool _isLoading = true;

  final TmdbServices _tmdbServices = TmdbServices();

  Future<void> _loadData() async {
    dataMap = await _tmdbServices.fetchCastDetails(widget.actorId);

    imageLink = "https://image.tmdb.org/t/p/w342/${widget.imagePath}";

    actorName = dataMap['name'] ?? '_';
    biography = dataMap['biography'] ?? '_';

    movieCredits = dataMap['movie_credits']['cast'];

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _loadData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double bgHeight = constraints.maxWidth * (3 / 4);

                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      SizedBox(
                        height: bgHeight,
                        width: constraints.maxWidth,
                        child: ClipRect(
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 15,
                              sigmaY: 15,
                              tileMode: TileMode.clamp,
                            ),
                            child: widget.imagePath.isEmpty && _isLoading
                                ? Image.asset(
                                    'assets/splash/logo.png',
                                    fit: BoxFit.cover,
                                  )
                                : FadeInImage(
                                    image: NetworkImage(imageLink),
                                    placeholder: const AssetImage(
                                      'assets/splash/logo.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withAlpha(254),

                                Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withAlpha(230),
                                Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withAlpha(150),

                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.1, 0.3, 0.5],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Hero(
                            tag: 'profileImage_${widget.actorId}',
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blueAccent, // Border color
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: widget.imagePath.isEmpty && _isLoading
                                    ? Container(
                                        padding: EdgeInsets.all(
                                          2,
                                        ), // Small inner padding
                                        child: Image.asset(
                                          'assets/splash/logo.png',
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                        ),
                                      )
                                    : Container(
                                        padding: EdgeInsets.all(2),
                                        child: FadeInImage(
                                          image: NetworkImage(imageLink),
                                          placeholder: const AssetImage(
                                            'assets/splash/logo.png',
                                          ),
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withAlpha(60),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                ),
                                color: Theme.of(context).primaryColor,
                                focusColor: lightblueColor,
                                tooltip: 'Go back',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              //DETAILS
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(25, 5, 25, 25),
                child: Column(
                  children: [
                    Text(
                      _isLoading ? "" : actorName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontSize: 25),
                    ).redacted(context: context, redact: _isLoading),
                    SizedBox(height: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Text(
                            "Biography",

                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 0.3,
                                ),
                          ).redacted(context: context, redact: _isLoading),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _isLoading ? "" : biography,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.normal,
                              ),
                        ).redacted(context: context, redact: _isLoading),
                      ],
                    ),
                  ],
                ),
              ),

              _isLoading
                  ? SizedBox()
                  : HorizontalSliderWidget(
                      title: "Featured In",
                      endpoint: "movie",
                      dataList: movieCredits,
                      totalPages: 1,
                      showmoreButton: false,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
