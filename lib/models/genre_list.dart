class GenreListClass {
  static List<Map<String, dynamic>> movieGenreList = [
    {'id': 28, 'name': 'Action'},
    {'id': 12, 'name': 'Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 99, 'name': 'Documentary'},
    {'id': 18, 'name': 'Drama'},
    {'id': 10751, 'name': 'Family'},
    {'id': 14, 'name': 'Fantasy'},
    {'id': 36, 'name': 'History'},
    {'id': 27, 'name': 'Horror'},
    {'id': 10402, 'name': 'Music'},
    {'id': 9648, 'name': 'Mystery'},
    {'id': 10749, 'name': 'Romance'},
    {'id': 878, 'name': 'Science Fiction'},
    {'id': 10770, 'name': 'TV Movie'},
    {'id': 53, 'name': 'Thriller'},
    {'id': 10752, 'name': 'War'},
    {'id': 37, 'name': 'Western'},
  ];

  static List<Map<String, dynamic>> tvGenreList = [
    {'id': 10759, 'name': 'Action & Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 99, 'name': 'Documentary'},
    {'id': 18, 'name': 'Drama'},
    {'id': 10751, 'name': 'Family'},
    {'id': 10762, 'name': 'Kids'},
    {'id': 37, 'name': 'Western'},
    {'id': 10763, 'name': 'News'},
    {'id': 10764, 'name': 'Reality'},
    {'id': 10765, 'name': 'Sci-Fi & Fantasy'},
    {'id': 10766, 'name': 'Soap'},
    {'id': 10767, 'name': 'Talk'},
    {'id': 10768, 'name': 'War & Politics'},
  ];

  static List<Map<String, dynamic>> getAllGenreList() {
    return (movieGenreList + tvGenreList).toSet().toList();
  }

  // Hardcoded genre map for quick lookup
  static const Map<int, String> genreMap = {
    // Movie Genres
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
    // TV Genres
    10759: 'Action & Adventure',
    10762: 'Kids',
    10763: 'News',
    10764: 'Reality',
    10765: 'Sci-Fi & Fantasy',
    10766: 'Soap',
    10767: 'Talk',
    10768: 'War & Politics',
  };

  static Map<int, String> getGenreMap() {
    return genreMap;
  }

  static List<Map<String, dynamic>> getTvGenreList() {
    return tvGenreList;
  }

  static List<Map<String, dynamic>> getMovieGenreList() {
    return movieGenreList;
  }
}
