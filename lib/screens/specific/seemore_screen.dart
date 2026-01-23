import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/widgets/appbar_with_title.dart';
import 'package:cine_echo/widgets/grid_view.dart';
import 'package:flutter/material.dart';

class SeemoreScreen extends StatelessWidget {
  final String endpoint;
  final String appbarTitle;

  const SeemoreScreen({
    super.key,
    required this.endpoint,
    required this.appbarTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWithTitle(title: appbarTitle),
      body: ContentSection(endpoint: endpoint),
    );
  }
}


// Content Section -> handle data loading.
class ContentSection extends StatefulWidget {
  final String endpoint;
  const ContentSection({super.key, required this.endpoint});

  @override
  State<ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<ContentSection> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  late List<dynamic> resultList;
  int _currentPage = 1;
  int _totalPages = 1;
  final TmdbServices _tmdbServices = TmdbServices();

  Future<void> _loadData({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        _currentPage = 1;
      }
      final data = await _tmdbServices.fetchSectionData(widget.endpoint);
      if (mounted) {
        setState(() {
          if (loadMore) {
            resultList.addAll(data['results']);
            _isLoadingMore = false;
          } else {
            resultList = data['results'];
            _isLoading = false;
          }
          _totalPages = data['total_pages'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _loadMoreData() {
    if (_currentPage < _totalPages && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _loadData(loadMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridViewWidget(
                  dataList: resultList,
                  onLoadMore: _loadMoreData,
                  isLoadingMore: _isLoadingMore,
                  hasMorePages: _currentPage < _totalPages,
                ),
        ),
      ],
    );
  }
}
