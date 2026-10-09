import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lyric_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<LyricModel>> getFavorites();
  Future<void> saveFavorite(LyricModel lyric);
  Future<void> removeFavorite(int lyricId);
  Future<bool> isFavorite(int lyricId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static const String _favoritesKey = 'favorite_lyrics_list';
  final SharedPreferences? _prefs;

  FavoritesLocalDataSourceImpl({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<List<LyricModel>> getFavorites() async {
    final prefs = await _getPrefs();
    final rawList = prefs.getStringList(_favoritesKey) ?? [];
    return rawList.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return LyricModel.fromJson(decoded);
    }).toList();
  }

  @override
  Future<void> saveFavorite(LyricModel lyric) async {
    final prefs = await _getPrefs();
    final currentList = await getFavorites();
    if (!currentList.any((item) => item.id == lyric.id)) {
      currentList.insert(0, lyric);
      final rawList = currentList.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_favoritesKey, rawList);
    }
  }

  @override
  Future<void> removeFavorite(int lyricId) async {
    final prefs = await _getPrefs();
    final currentList = await getFavorites();
    currentList.removeWhere((item) => item.id == lyricId);
    final rawList = currentList.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_favoritesKey, rawList);
  }

  @override
  Future<bool> isFavorite(int lyricId) async {
    final currentList = await getFavorites();
    return currentList.any((item) => item.id == lyricId);
  }
}

