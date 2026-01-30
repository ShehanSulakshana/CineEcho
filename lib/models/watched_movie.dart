class WatchedMovie {
  final int tmdbId;
  final DateTime watchedAt;
  final bool isFavorite;

  WatchedMovie({
    required this.tmdbId,
    required this.watchedAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'tmdbId': tmdbId,
    'watchedAt': watchedAt.toIso8601String(),
    'isFavorite': isFavorite,
  };

  factory WatchedMovie.fromJson(Map<String, dynamic> json) => WatchedMovie(
    tmdbId: json['tmdbId'] as int,
    watchedAt: DateTime.parse(json['watchedAt'] as String),
    isFavorite: json['isFavorite'] as bool? ?? false,
  );
}
