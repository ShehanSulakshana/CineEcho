import 'package:flutter/material.dart';

Widget completedStatsCard(String watchTime, int movies, int episodes) {
  return IntrinsicHeight(
    child: Card(
      color: Color.fromARGB(255, 10, 40, 60),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _statColumn(
                Icons.timelapse,
                Colors.lightBlue,
                'Total WatchTime',
                watchTime,
              ),
            ),
            VerticalDivider(color: Colors.blue[700]!, thickness: 1),
            Expanded(
              child: _statColumn(
                Icons.movie,
                Colors.blue,
                'Movies',
                movies.toString(),
              ),
            ),
            VerticalDivider(color: Colors.blue[700]!, thickness: 1),
            Expanded(
              child: _statColumn(
                Icons.tv,
                Colors.lightBlue,
                'Tv Episodes',
                episodes.toString(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _statColumn(IconData icon, Color iconColor, String label, String value) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: iconColor, size: 28),
      SizedBox(height: 6),
      Text(label, style: TextStyle(color: Colors.white70, fontSize: 11)),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
