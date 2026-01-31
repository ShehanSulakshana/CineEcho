import 'package:cine_echo/models/watch_history_repository.dart';
import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/screens/specific/details_screen.dart';
import 'package:flutter/material.dart';

class FavoritesTab extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const FavoritesTab({super.key, this.onDataChanged});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final WatchHistoryRepository _watchRepo = WatchHistoryRepository();
  final TmdbServices _tmdbServices = TmdbServices();
  List<Map<String, dynamic>> _favoriteItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final movies = await _watchRepo.getFavoritedMovies();
    final series = await _watchRepo.getFavoritedSeries();

    List<Map<String, dynamic>> items = [];

    items.addAll(
      movies.map(
        (movie) => {
          'type': 'movie',
          'id': movie.tmdbId,
          'timestamp': movie.favoritedAt,
        },
      ),
    );

    items.addAll(
      series.map(
        (s) => {
          'type': 'series',
          'id': s.seriesTmdbId,
          'timestamp': s.favoritedAt,
        },
      ),
    );

    items.sort(_compareByMostRecent);

    setState(() {
      _favoriteItems = items;
      _isLoading = false;
    });
  }

  int _compareByMostRecent(Map<String, dynamic> a, Map<String, dynamic> b) {
    DateTime aTime = a['timestamp'] as DateTime;
    DateTime bTime = b['timestamp'] as DateTime;
    return bTime.compareTo(aTime);
  }

  void _showDeleteDialog(String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red[400], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Remove Favorite',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Remove "$title" from your favorites?',
          style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_favoriteItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 64,
                color: Colors.white.withAlpha(77),
              ),
              const SizedBox(height: 16),
              Text(
                'No favorites yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(153),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start adding your favorite movies and TV series!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(102),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: _favoriteItems.length,
      itemBuilder: (context, index) {
        final item = _favoriteItems[index];
        if (item['type'] == 'movie') {
          return _buildFavoriteMovieCard(item['id'] as int);
        } else {
          return _buildFavoritedSeriesCard(item['id'] as int);
        }
      },
    );
  }

  Widget _buildFavoriteMovieCard(int movieId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _tmdbServices.fetchDetails(
        movieId.toString(),
        'movie',
        isSeason: false,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final data = snapshot.data!;
        final posterPath = data['poster_path'];
        final title = data['title'] ?? 'Unknown';
        final releaseDate = data['release_date'] ?? '';
        final rating = data['vote_average']?.toStringAsFixed(1) ?? 'N/A';
        final overview = data['overview'] ?? '';

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  dataMap: data,
                  typeData: 'movie',
                  id: movieId.toString(),
                  heroSource: 'favorite_$movieId',
                ),
              ),
            );
            if (mounted) {
              _loadFavorites();
            }
          },
          onLongPress: () {
            _showDeleteDialog(title, () async {
              await _watchRepo.unmarkMovieFavorite(movieId);
              if (mounted) {
                _loadFavorites();
                widget.onDataChanged?.call();
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withAlpha(128), width: 1),
            ),
            child: Row(
              children: [
                if (posterPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w92$posterPath',
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.movie_outlined,
                            color: Colors.white.withAlpha(77),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.movie_outlined,
                      color: Colors.white.withAlpha(77),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (releaseDate.isNotEmpty)
                        Text(
                          releaseDate.substring(0, 4),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(153),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(204),
                            ),
                          ),
                        ],
                      ),
                      if (overview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          overview,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(128),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritedSeriesCard(int seriesId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _tmdbServices.fetchDetails(
        seriesId.toString(),
        'tv',
        isSeason: false,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final data = snapshot.data!;
        final posterPath = data['poster_path'];
        final title = data['name'] ?? 'Unknown';
        final firstAirDate = data['first_air_date'] ?? '';
        final rating = data['vote_average']?.toStringAsFixed(1) ?? 'N/A';
        final overview = data['overview'] ?? '';

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  dataMap: data,
                  typeData: 'tv',
                  id: seriesId.toString(),
                  heroSource: 'favorites_series_$seriesId',
                ),
              ),
            );
            if (mounted) {
              _loadFavorites();
            }
          },
          onLongPress: () {
            _showDeleteDialog(title, () async {
              await _watchRepo.unmarkSeriesFavorite(seriesId);
              if (mounted) {
                _loadFavorites();
                widget.onDataChanged?.call();
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withAlpha(128), width: 1),
            ),
            child: Row(
              children: [
                if (posterPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w92$posterPath',
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tv_outlined,
                            color: Colors.white.withAlpha(77),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tv_outlined,
                      color: Colors.white.withAlpha(77),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (firstAirDate.isNotEmpty)
                        Text(
                          firstAirDate.substring(0, 4),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(153),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(204),
                            ),
                          ),
                        ],
                      ),
                      if (overview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          overview,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(128),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

