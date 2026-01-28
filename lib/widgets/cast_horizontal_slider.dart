import 'package:cine_echo/screens/specific/cast_details.dart';
import 'package:flutter/material.dart';
import 'package:redacted/redacted.dart';

class CastHorizontalSlider extends StatelessWidget {
  final List<dynamic> castList;
  final bool isLoading;
  final bool fromCast;
  const CastHorizontalSlider({
    super.key,
    required this.castList,
    required this.isLoading,
    this.fromCast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            "Cast",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
        ).redacted(context: context, redact: isLoading),
        SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: castList.length,
            itemBuilder: (BuildContext context, int index) {
              final itemMap = castList[index];
              final actorId = itemMap['id'];
              final name = itemMap['name'] ?? 'Unknown';
              final character = itemMap['character'] ?? 'Unknown';
              final image = itemMap['profile_path'];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                width: 110,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CastDetails(
                          actorId: actorId.toString(),
                          imagePath: image,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: Hero(
                          tag: fromCast
                              ? 'inActive$actorId'
                              : 'profileImage_$actorId',
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(100),
                            child: image == null
                                ? Image.asset(
                                    'assets/splash/logo.png',
                                    fit: BoxFit.cover,
                                  )
                                : FadeInImage(
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w342/$image',
                                    ),
                                    placeholder: const AssetImage(
                                      'assets/splash/logo.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Actor Name
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 13,
                          letterSpacing: 0.2,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      // Character Name
                      Text(
                        character,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 0.1,
                          fontStyle: FontStyle.italic,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
