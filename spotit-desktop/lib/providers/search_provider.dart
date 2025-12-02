import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/youtube_service.dart';

class SearchProvider extends ChangeNotifier {
  final YouTubeService _youtubeService = YouTubeService();
  
  List<Song> _searchResults = [];
  bool _isLoading = false;
  String _error = '';
  
  List<Song> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  /// Search for songs on YouTube
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      // Use the YouTube service to search
      // The service returns Song objects directly now
      _searchResults = await _youtubeService.search(query);
      
      if (_searchResults.isEmpty) {
        _error = 'No results found for "$query"';
      }
    } catch (e) {
      _error = 'Error searching: $e';
      print('Search error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _error = '';
    notifyListeners();
  }
  
  @override
  void dispose() {
    _youtubeService.dispose();
    super.dispose();
  }
}
