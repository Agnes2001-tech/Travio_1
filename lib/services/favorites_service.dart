import 'package:flutter/foundation.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final ValueNotifier<List<Map<String, dynamic>>> savedItems = ValueNotifier([]);

  void toggleFavorite(Map<String, dynamic> item) {
    final current = List<Map<String, dynamic>>.from(savedItems.value);
    final String id = item['id'].toString();
    final index = current.indexWhere((i) => i['id'].toString() == id);
    
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(item);
    }
    savedItems.value = current;
  }

  bool isFavorite(dynamic id) {
    if (id == null) return false;
    final String idStr = id.toString();
    return savedItems.value.any((i) => i['id']?.toString() == idStr);
  }
}
