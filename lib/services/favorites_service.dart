import 'package:flutter/foundation.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final ValueNotifier<List<Map<String, dynamic>>> savedItems = ValueNotifier([]);

  void toggleFavorite(Map<String, dynamic> item) {
    final current = List<Map<String, dynamic>>.from(savedItems.value);
    final index = current.indexWhere((i) => i['id'] == item['id']);
    
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(item);
    }
    savedItems.value = current;
  }

  bool isFavorite(String id) {
    return savedItems.value.any((i) => i['id'] == id);
  }
}
