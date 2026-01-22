import 'package:flutter/material.dart';

class HorizontalSliderWidget extends StatelessWidget {
  final String title;
  final List<dynamic> dataList;
  const HorizontalSliderWidget({
    super.key,
    required this.title,
    required this.dataList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        SizedBox(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    //TODO: Navigate to full list
                  },
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Scroll
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: 20,
            itemBuilder: (context, index) {
              final item = dataList[index];
              final title = item['title'] ?? item['name'] ?? 'Unknown';
              final releaseYear = DateTime.parse(
                item['first_air_date'] ?? item['release_date'],
              ).year.toString();
              final imagePath = item['poster_path'];
              final imageLink = "https://image.tmdb.org/t/p/w400$imagePath";

              bool imageLoadingError = false;
              if (imagePath == null) {
                imageLoadingError = true;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    //TODO: Navigate to movie details
                  },
                  child: SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster (smaller)
                        Container(
                          width: 90,
                          height: 135,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageLink.isEmpty || imageLoadingError
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
                                    height: double.infinity,
                                    width: double.infinity,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: 90,
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Year + Rating (smaller)
                        Text(
                          releaseYear,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
