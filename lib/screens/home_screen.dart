import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/amadeus_service.dart';
import '../services/favorites_service.dart';
import 'destination_details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AmadeusService _amadeusService = AmadeusService();
  final FavoritesService _favoritesService = FavoritesService();
  
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final coords = await _amadeusService.getCityCoordinates('PAR');
      final results = await _amadeusService.getToursAndActivities(
        lat: coords['lat']!,
        lon: coords['lon']!,
      );
      if (mounted) {
        setState(() {
          _activities = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Failed to load activities: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT LOCATION',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                          letterSpacing: 1,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Paris, France',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, size: 20),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                onSubmitted: (val) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search flights, hotels, or cities...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _categoryChip(Icons.flight, 'Flights', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  }),
                  _categoryChip(Icons.hotel, 'Hotels', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  }),
                  _categoryChip(Icons.map_outlined, 'Places', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  }),
                  _categoryChip(Icons.card_giftcard, 'Packages', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _favoritesService.savedItems,
                builder: (context, favorites, _) {
                  if (favorites.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saved for You',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final item = favorites[index];
                            return _savedItemCard(item);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Recommended Activities',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadData,
                    child: const Text('Refresh', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_activities.isEmpty)
                const Center(child: Text('No activities found.'))
              else
                ..._activities.take(5).map((activity) => _activityItem(activity)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _savedItemCard(Map<String, dynamic> item) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name'] ?? 'Saved Item',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Spacer(),
          Text(
            item['type'] ?? 'Travel',
            style: const TextStyle(color: AppColors.primary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _activityItem(Map<String, dynamic> activity) {
    final name = activity['name'] ?? 'Activity';
    final price = activity['price']?['amount'] ?? '0';
    final currency = activity['price']?['currencyCode'] ?? 'EUR';
    final pic = activity['pictures'] != null && (activity['pictures'] as List).isNotEmpty
        ? activity['pictures'][0]
        : 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=200';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DestinationDetailsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                pic,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.broken_image, color: AppColors.primary),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$price $currency',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _favoritesService.isFavorite(activity['id'].toString())
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            _favoritesService.toggleFavorite({
                              'id': activity['id'],
                              'name': name,
                              'type': 'Activity',
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
