import 'dart:async';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/soundcloud_service.dart';

class SearchProvider with ChangeNotifier {
  final SoundCloudService _scService = SoundCloudService();
  
  List<Song> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  List<Song> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isLoading = true;
      _error = '';
      notifyListeners();

      try {
        _searchResults = await _scService.searchSongs(query);
      } catch (e) {
        _error = e.toString();
        _searchResults = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void clearSearch() {
    _searchResults = [];
    _error = '';
    notifyListeners();
  }
}
