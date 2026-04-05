import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import '../services/favorites_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/stardust_background.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const Text(
          'Saved Experience',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: StardustBackground(
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: favoritesService.savedItems,
          builder: (context, favorites, _) {
            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      borderRadius: 100,
                      child: Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.textGrey.withOpacity(0.3)),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Your collection is empty',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Curate your next journey by liking\npremium destinations and flights.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 20, 10),
                  child: Text(
                    '${favorites.length} CURATED ITEMS',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (_, i) {
                      final item = favorites[i];
                      final String name = item['name'] ?? 'Unknown';
                      final String type = item['type'] ?? 'Travel';
                      final String price = item['price']?.toString() ?? '';
                      final String currency = item['currency'] ?? '';

                      return GestureDetector(
                        onTap: () => Fluttertoast.showToast(msg: name),
                        child: GlassContainer(
                          borderRadius: 24,
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                // Background Image
                                Positioned.fill(
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(color: AppColors.obsidianTertiary, child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textGrey)),
                                  ),
                                ),
                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.obsidian.withOpacity(0.9),
                                        AppColors.obsidian.withOpacity(0.2),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.4, 1.0],
                                    ),
                                  ),
                                ),
                                // Unfavorite Button
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () {
                                        favoritesService.toggleFavorite(item);
                                        Fluttertoast.showToast(msg: 'Removed from favorites');
                                    },
                                    child: GlassContainer(
                                      padding: const EdgeInsets.all(8),
                                      borderRadius: 12,
                                      child: const Icon(
                                        Icons.favorite_rounded,
                                        color: Colors.redAccent,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                // Content Information
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          type.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (price.isNotEmpty && price != '0')
                                        Text(
                                          '$currency $price',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
