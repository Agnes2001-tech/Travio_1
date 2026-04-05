import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import 'booking_screen.dart';
import '../models/hotel_model.dart';
import '../widgets/glass_container.dart';
import '../widgets/stardust_background.dart';

class DestinationDetailsScreen extends StatefulWidget {
  const DestinationDetailsScreen({super.key});
  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: StardustBackground(
        opacity: 0.05,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 320,
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'dest-hero',
                          child: Image.network(
                            'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
                            width: double.infinity,
                            height: 320,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                                AppColors.obsidian.withOpacity(0.8),
                                AppColors.obsidian,
                              ],
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: GlassContainer(
                                    padding: const EdgeInsets.all(8),
                                    borderRadius: 12,
                                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Fluttertoast.showToast(msg: 'Shared!'),
                                      child: GlassContainer(
                                        padding: const EdgeInsets.all(8),
                                        borderRadius: 12,
                                        child: const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => _saved = !_saved);
                                        Fluttertoast.showToast(msg: _saved ? 'Added to favorites!' : 'Removed!');
                                      },
                                      child: GlassContainer(
                                        padding: const EdgeInsets.all(8),
                                        borderRadius: 12,
                                        child: Icon(
                                          _saved ? Icons.favorite : Icons.favorite_border,
                                          color: _saved ? Colors.redAccent : AppColors.textPrimary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Santorini, Greece',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.star, size: 18),
                            const Text(
                              ' 4.9 (1,248 Reviews)',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: const Text(
                                'OIA, GREECE',
                                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'About Destination',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Experience breathtaking sunsets and iconic blue-domed churches in one of the most beautiful islands in the world. Enjoy luxury stays and Mediterranean cuisine with a panoramic view of the Aegean Sea.',
                          style: TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Facilities',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _facility(Icons.wifi_rounded, 'Free WiFi'),
                            _facility(Icons.pool_rounded, 'Pool'),
                            _facility(Icons.restaurant_rounded, 'Breakfast'),
                            _facility(Icons.spa_rounded, 'Spa'),
                            _facility(Icons.ac_unit_rounded, 'A/C'),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Gallery',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            TextButton(
                              onPressed: () => Fluttertoast.showToast(msg: 'See All Photos'),
                              child: const Text('See all', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _galleryImg('https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=200'),
                              _galleryImg('https://images.unsplash.com/photo-1555993539-1732b0258235?w=200'),
                              _galleryImg('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200'),
                              _galleryImg('https://images.unsplash.com/photo-1533105079780-92b9be482077?w=200'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassContainer(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                borderRadius: 0, // Flat bottom for edge-to-edge
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PRICE FROM',
                          style: TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '₹ 35,000 / night',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(
                              hotel: HotelOffer(
                                name: 'Santorini Luxury Suite',
                                price: '35000',
                                currency: 'INR',
                                hotelId: 'SAN123',
                                boardType: 'All Inclusive',
                                checkInDate: '2024-05-01',
                              ),
                            ),
                          ),
                        ),
                        child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _facility(IconData icon, String label) => Column(
    children: [
      GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 14,
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      ),
    ],
  );

  Widget _galleryImg(String url) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Hero(
      tag: 'gallery-$url',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 100,
            height: 100,
            color: AppColors.obsidianTertiary,
            child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textGrey),
          ),
        ),
      ),
    ),
  );
}
