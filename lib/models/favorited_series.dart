class FavoritedSeries {
  final int seriesTmdbId;
  final DateTime favoritedAt;

  FavoritedSeries({required this.seriesTmdbId, required this.favoritedAt});

  Map<String, dynamic> toJson() => {
    'seriesTmdbId': seriesTmdbId,
    'favoritedAt': favoritedAt.toIso8601String(),
  };

  factory FavoritedSeries.fromJson(Map<String, dynamic> json) =>
      FavoritedSeries(
        seriesTmdbId: json['seriesTmdbId'] as int,
        favoritedAt: DateTime.parse(json['favoritedAt'] as String),
      );
}
