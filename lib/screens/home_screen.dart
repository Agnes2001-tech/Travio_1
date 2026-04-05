import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import '../services/amadeus_service.dart';
import '../services/favorites_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/stardust_background.dart';
import 'destination_details_screen.dart';
import 'search_screen.dart';
import 'main_shell.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AmadeusService _amadeusService = AmadeusService();
  final FavoritesService _favoritesService = FavoritesService();
  final LocationService _locationService = LocationService();
  
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locationService.currentLocation.addListener(_onLocationChanged);
    _loadData();
  }

  @override
  void dispose() {
    _locationService.currentLocation.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onLocationChanged() {
    if (mounted) {
      setState(() => _isLoading = true);
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final loc = _locationService.currentLocation.value;
      final results = await _amadeusService.getToursAndActivities(
        lat: loc.lat,
        lon: loc.lon,
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

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => GlassContainer(
            borderRadius: 30,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    'Explore 50+ Global Hubs',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: LocationService.availableCities.length,
                    itemBuilder: (context, index) {
                      final city = LocationService.availableCities[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_city_rounded, color: AppColors.primary, size: 22),
                        ),
                        title: Text(city.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        subtitle: Text(city.cityCode, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        onTap: () {
                          _locationService.updateLocation(city);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: StardustBackground(
        opacity: 0.05,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showCitySelector,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EXPLORE FROM',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ValueListenableBuilder<LocationData>(
                              valueListenable: _locationService.currentLocation,
                              builder: (context, loc, _) => Row(
                                children: [
                                  Text(
                                    loc.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GlassContainer(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 12,
                      child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Search Bar
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 20,
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Search luxury stays or flights...',
                            style: TextStyle(color: AppColors.textGrey, fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Trending Activities
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TRENDING NOW',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textGrey,
                        letterSpacing: 2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _activities.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            width: double.infinity,
                            child: const Center(
                              child: Text('No activities found in this city yet.', style: TextStyle(color: AppColors.textGrey)),
                            ),
                          )
                        : SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _activities.length,
                              itemBuilder: (context, index) {
                                final act = _activities[index];
                                return _activityCard(act);
                              },
                            ),
                          ),
                
                const SizedBox(height: 32),
                
                // Discover Section
                const Text(
                  'PREMIUM DESTINATIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textGrey,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                _destinationCard(
                  'Santorini, Greece',
                  'A timeless luxury escape with iconic caldera views.',
                  'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=600',
                  '₹ 45,000',
                ),
                const SizedBox(height: 16),
                _destinationCard(
                  'Swiss Alps, Zermatt',
                  'Unparalleled winter luxury at the foot of Matterhorn.',
                  'https://images.unsplash.com/photo-1502784444187-359ac186c5bb?w=600',
                  '₹ 82,000',
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityCard(Map<String, dynamic> act) {
    final name = act['name'] ?? 'Luxury Activity';
    final price = act['price']?['amount'] ?? 'Price on request';
    final imageUrl = (act['pictures'] != null && (act['pictures'] as List).isNotEmpty)
        ? act['pictures'][0]
        : 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400';

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
            // Simplified navigation for activities
            Fluttertoast.showToast(msg: name);
        },
        child: GlassContainer(
          borderRadius: 24,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${LocationService.currencySymbol} $price',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Icon(Icons.favorite_border_rounded, color: AppColors.textGrey, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _destinationCard(String title, String subtitle, String img, String price) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DestinationDetailsScreen())),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(img, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('From $price', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
