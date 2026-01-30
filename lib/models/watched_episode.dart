class WatchedEpisode {
  final int seriesTmdbId;
  final int seasonNumber;
  final int episodeNumber;
  final DateTime watchedAt;

  WatchedEpisode({
    required this.seriesTmdbId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.watchedAt,
  });

  String get episodeKey => '${seriesTmdbId}_S${seasonNumber}E$episodeNumber';

  Map<String, dynamic> toJson() => {
    'seriesTmdbId': seriesTmdbId,
    'seasonNumber': seasonNumber,
    'episodeNumber': episodeNumber,
    'watchedAt': watchedAt.toIso8601String(),
  };

  factory WatchedEpisode.fromJson(Map<String, dynamic> json) => WatchedEpisode(
    seriesTmdbId: json['seriesTmdbId'] as int,
    seasonNumber: json['seasonNumber'] as int,
    episodeNumber: json['episodeNumber'] as int,
    watchedAt: DateTime.parse(json['watchedAt'] as String),
  );
}
