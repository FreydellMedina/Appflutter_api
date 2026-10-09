import 'package:flutter/foundation.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/lyric.dart';
import '../../domain/usecases/search_lyrics_usecase.dart';

enum LyricsSearchStatus { initial, loading, loaded, empty, error }

class LyricsSearchController extends ChangeNotifier {
  final SearchLyricsUseCase _searchLyricsUseCase;

  LyricsSearchController(this._searchLyricsUseCase);

  LyricsSearchStatus _status = LyricsSearchStatus.initial;
  LyricsSearchStatus get status => _status;

  List<Lyric> _rawLyrics = [];
  List<Lyric> _lyrics = [];
  List<Lyric> get lyrics => _lyrics;

  Lyric? _selectedLyric;
  Lyric? get selectedLyric => _selectedLyric;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  // Filter properties
  String _filterTrackName = '';
  String get filterTrackName => _filterTrackName;

  String _filterArtistName = '';
  String get filterArtistName => _filterArtistName;

  String _filterAlbumName = '';
  String get filterAlbumName => _filterAlbumName;

  bool _onlySynced = false;
  bool get onlySynced => _onlySynced;

  bool get hasActiveFilters =>
      _filterTrackName.isNotEmpty ||
      _filterArtistName.isNotEmpty ||
      _filterAlbumName.isNotEmpty ||
      _onlySynced;

  int get activeFilterCount {
    int count = 0;
    if (_filterTrackName.isNotEmpty) count++;
    if (_filterArtistName.isNotEmpty) count++;
    if (_filterAlbumName.isNotEmpty) count++;
    if (_onlySynced) count++;
    return count;
  }

  void _applyLocalFilters() {
    if (_onlySynced) {
      _lyrics = _rawLyrics.where((item) => item.hasSyncedLyrics).toList();
    } else {
      _lyrics = List.from(_rawLyrics);
    }
  }

  void toggleOnlySynced() {
    _onlySynced = !_onlySynced;
    _applyLocalFilters();
    if (_status == LyricsSearchStatus.loaded || _status == LyricsSearchStatus.empty) {
      _status = _lyrics.isEmpty ? LyricsSearchStatus.empty : LyricsSearchStatus.loaded;
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      _rawLyrics = [];
      _lyrics = [];
      _status = LyricsSearchStatus.initial;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _currentQuery = clean;
    _status = LyricsSearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _searchLyricsUseCase(clean);
      _rawLyrics = results;
      _applyLocalFilters();
      _status = _lyrics.isEmpty ? LyricsSearchStatus.empty : LyricsSearchStatus.loaded;
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      _status = LyricsSearchStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> searchDetailed({
    String? trackName,
    String? artistName,
    String? albumName,
    bool? onlySynced,
  }) async {
    _filterTrackName = (trackName ?? '').trim();
    _filterArtistName = (artistName ?? '').trim();
    _filterAlbumName = (albumName ?? '').trim();
    if (onlySynced != null) {
      _onlySynced = onlySynced;
    }

    final hasCriteria = _filterTrackName.isNotEmpty ||
        _filterArtistName.isNotEmpty ||
        _filterAlbumName.isNotEmpty;

    if (!hasCriteria) {
      if (_currentQuery.isNotEmpty) {
        await search(_currentQuery);
      } else {
        _rawLyrics = [];
        _lyrics = [];
        _status = LyricsSearchStatus.initial;
        notifyListeners();
      }
      return;
    }

    _status = LyricsSearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _searchLyricsUseCase.searchDetailed(
        trackName: _filterTrackName.isEmpty ? null : _filterTrackName,
        artistName: _filterArtistName.isEmpty ? null : _filterArtistName,
        albumName: _filterAlbumName.isEmpty ? null : _filterAlbumName,
      );
      _rawLyrics = results;
      _applyLocalFilters();
      _status = _lyrics.isEmpty ? LyricsSearchStatus.empty : LyricsSearchStatus.loaded;
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      _status = LyricsSearchStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void clearFilters() {
    _filterTrackName = '';
    _filterArtistName = '';
    _filterAlbumName = '';
    _onlySynced = false;
    _applyLocalFilters();
    if (_rawLyrics.isNotEmpty) {
      _status = _lyrics.isEmpty ? LyricsSearchStatus.empty : LyricsSearchStatus.loaded;
    }
    notifyListeners();
  }

  void selectLyric(Lyric lyric) {
    _selectedLyric = lyric;
    notifyListeners();
  }
}