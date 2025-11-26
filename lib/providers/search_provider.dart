/**
 * Search Provider
 * 
 * Manages the state of song search functionality.
 * Handles search queries, results, and loading states.
 */

import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/api_service.dart';

class SearchProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Song> _results = [];
  String _query = '';
  bool _isLoading = false;
  String? _error;

  List<Song> get results => _results;
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasResults => _results.isNotEmpty;

  /// Search for songs
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      _query = '';
      _error = null;
      notifyListeners();
      return;
    }

    _query = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _apiService.search(query, limit: 20);
      _error = null;
    } catch (e) {
      print('Search error: $e');
      _error = 'Search failed. Please try again.';
      _results = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear search results
  void clearResults() {
    _results = [];
    _query = '';
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
