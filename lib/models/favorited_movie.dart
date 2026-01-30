class FavoritedMovie {
  final int tmdbId;
  final DateTime favoritedAt;

  FavoritedMovie({required this.tmdbId, required this.favoritedAt});

  Map<String, dynamic> toJson() => {
    'tmdbId': tmdbId,
    'favoritedAt': favoritedAt.toIso8601String(),
  };

  factory FavoritedMovie.fromJson(Map<String, dynamic> json) => FavoritedMovie(
    tmdbId: json['tmdbId'] as int,
    favoritedAt: DateTime.parse(json['favoritedAt'] as String),
  );
}
