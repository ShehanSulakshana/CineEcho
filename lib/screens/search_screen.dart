import 'package:cine_echo/providers/error_handler.dart';
import 'package:cine_echo/screens/specific/cast_details.dart';
import 'package:cine_echo/screens/specific/details_screen.dart';
import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TmdbServices _tmdbServices = TmdbServices();
  final FocusNode _searchFocusNode = FocusNode();

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults = [];
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchQuery = query;
      _hasSearched = true;
    });

    try {
      final results = await _tmdbServices.searchMulti(query);

      if (mounted) {
        setState(() {
          _searchResults = results['results'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
        ErrorHandler.handleError(context, e, 'Search failed');
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _hasSearched = false;
      _searchQuery = '';
    });
    _searchFocusNode.requestFocus();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blueColor.withAlpha(77), width: 1),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search movies, TV shows, people...',
          hintStyle: TextStyle(
            color: Colors.white.withAlpha(128),
            fontSize: 16,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: blueColor, size: 24),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.white70),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 100,
              color: Colors.white.withAlpha(77),
            ),
            const SizedBox(height: 24),
            Text(
              'Search for Movies, TV Shows & People',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(179),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start typing to discover amazing content',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(128),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 100,
              color: Colors.white.withAlpha(77),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white.withAlpha(204),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'We couldn\'t find anything for "$_searchQuery"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(128),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Try different keywords',
              style: TextStyle(fontSize: 13, color: blueColor.withAlpha(204)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildResultItem(Map<String, dynamic> item) {
    final mediaType = item['media_type'] ?? 'unknown';

    if (mediaType != 'movie' && mediaType != 'tv' && mediaType != 'person') {
      return const SizedBox.shrink();
    }

    final title = item['title'] ?? item['name'] ?? 'Unknown';
    final posterPath = item['poster_path'] ?? item['profile_path'];
    final imageUrl = posterPath != null
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : null;

    final overview = item['overview'] ?? '';
    final releaseDate = item['release_date'] ?? item['first_air_date'] ?? '';
    final year = releaseDate.isNotEmpty ? releaseDate.split('-')[0] : '';

    final rating = item['vote_average'] != null
        ? (item['vote_average'] as num).toStringAsFixed(1)
        : null;

    String mediaTypeLabel = '';
    IconData mediaIcon = Icons.movie;
    Color mediaColor = blueColor;

    switch (mediaType) {
      case 'movie':
        mediaTypeLabel = 'Movie';
        mediaIcon = Icons.movie_outlined;
        mediaColor = blueColor;
        break;
      case 'tv':
        mediaTypeLabel = 'TV Series';
        mediaIcon = Icons.tv;
        mediaColor = blueColor;
        break;
      case 'person':
        mediaTypeLabel = 'Person';
        mediaIcon = Icons.person;
        mediaColor = Colors.orangeAccent;
        break;
    }
    return GestureDetector(
      onTap: () {
        if (mediaType == 'person') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CastDetails(
                actorId: item['id'].toString(),
                imagePath: item['profile_path'] ?? '',
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                dataMap: item,
                typeData: mediaType,
                id: item['id'].toString(),
                heroSource: 'search',
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(26), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: imageUrl != null
                  ? SafeNetworkImage(
                      imageUrl: imageUrl,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      placeholder: _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: mediaColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: mediaColor.withAlpha(128),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(mediaIcon, size: 14, color: mediaColor),
                              const SizedBox(width: 4),
                              Text(
                                mediaTypeLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: mediaColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (year.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            year,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(153),
                            ),
                          ),
                        ],
                        if (rating != null && mediaType != 'person') ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(179),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (overview.isNotEmpty && mediaType != 'person') ...[
                      const SizedBox(height: 8),
                      Text(
                        overview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(153),
                          height: 1.4,
                        ),
                      ),
                    ],

                    if (mediaType == 'person' &&
                        item['known_for_department'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Known for: ${item['known_for_department']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(153),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white.withAlpha(77),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 150,
      color: Colors.white.withAlpha(26),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.white.withAlpha(77),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color.fromARGB(255, 39, 61, 254),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 39, 61, 254),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: blueColor),
                        const SizedBox(height: 16),
                        Text(
                          'Searching...',
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _searchResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _searchResults.length,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      return _buildResultItem(_searchResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

