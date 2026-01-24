import 'package:flutter/material.dart';

class CastHorizontalSlider extends StatelessWidget {
  //final List<Map<String, dynamic>> castList;
  const CastHorizontalSlider({super.key}); // required this.castList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            "Cast",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, //castList.length,
            itemBuilder: (BuildContext context, int index) {
              // final itemMap = castList[index];
              // final name = itemMap['name'] ?? 'Unknown';
              // final character = itemMap['character'] ?? 'Unknown';
              // final image = itemMap['profile_path'];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                // width: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(100),
                        child: Image.asset(
                          'assets/images/poster.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Actor Name ",
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Character Name",
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
