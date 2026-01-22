import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class GridViewWidget extends StatelessWidget {
  final List<dynamic> dataList;
  const GridViewWidget({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
      ),
      itemCount: dataList.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 20, bottom: 100),
      itemBuilder: (BuildContext context, int index) {
        final item = dataList[index];
        final title = item['title'] ?? item['name'] ?? 'Unknown';
        final releaseYear =
            (item['first_air_date'] ?? item['release_date']) != null
            ? DateTime.parse(
                item['first_air_date'] ?? item['release_date'],
              ).year.toString()
            : 'Unknown';
        final imagePath = item['poster_path'];
        final imageLink = "https://image.tmdb.org/t/p/w400$imagePath";

        bool imageLoadingError = false;
        if (imagePath == null) {
          imageLoadingError = true;
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                //TODO: Navigate to movie details
              },
              child: SizedBox(
                //width: 90,
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
