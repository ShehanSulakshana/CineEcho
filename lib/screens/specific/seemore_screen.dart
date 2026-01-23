import 'package:cine_echo/services/tmdb_services.dart';
import 'package:cine_echo/widgets/appbar_with_title.dart';
import 'package:cine_echo/widgets/grid_view.dart';
import 'package:flutter/material.dart';

class SeemoreScreen extends StatelessWidget {
  final String endpoint;
  final String appbarTitle;
  final List<dynamic> initialData;
  final int initialTotalPages;

  const SeemoreScreen({
    super.key,
    required this.endpoint,
    required this.appbarTitle,
    required this.initialData,
    this.initialTotalPages = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWithTitle(title: appbarTitle),
      body: ContentSection(
        endpoint: endpoint,
        initialData: initialData,
        initialTotalPages: initialTotalPages,
      ),
    );
  }
}

// Content Section -> handle data loading.
class ContentSection extends StatefulWidget {
  final String endpoint;
  final List<dynamic> initialData;
  final int initialTotalPages;
  const ContentSection({
    super.key,
    required this.endpoint,
    required this.initialData,
    required this.initialTotalPages,
  });

  @override
  State<ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<ContentSection> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isRequestInFlight = false;
  late List<dynamic> resultList;
  int _currentPage = 1;
  int _totalPages = 1;
  final TmdbServices _tmdbServices = TmdbServices();

  Future<void> _loadData({bool loadMore = false}) async {
    if (_isRequestInFlight) return; 
    try {
      _isRequestInFlight = true;
      if (!loadMore) {
        _currentPage = 1;
      }
      final data = await _tmdbServices.fetchSectionData(
        widget.endpoint,
        page: _currentPage,
      );
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
    } finally {
      _isRequestInFlight = false;
    }
  }

  Future<void> _onRefresh() async {
    _isLoadingMore = false; 
    await _loadData(loadMore: false);
  }

  void _loadMoreData() {
    if (_currentPage >= _totalPages || _isLoadingMore || _isRequestInFlight) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    _loadData(loadMore: true);
  }

  @override
  void initState() {
    super.initState();
    resultList = List<dynamic>.from(widget.initialData);
    _totalPages = widget.initialTotalPages;
    _isLoading = resultList.isEmpty;
    if (resultList.isEmpty) {
      _loadData();
    }
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
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: GridViewWidget(
                    dataList: resultList,
                    onLoadMore: _loadMoreData,
                    isLoadingMore: _isLoadingMore,
                    hasMorePages: _currentPage < _totalPages,
                  ),
                ),
        ),
      ],
    );
  }
}
