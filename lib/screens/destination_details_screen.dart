import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import 'booking_screen.dart';
import '../models/hotel_model.dart';

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 280,
                  child: Stack(
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.arrow_back,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      Fluttertoast.showToast(msg: 'Shared!'),
                                  icon: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.share,
                                      color: AppColors.textDark,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _saved = !_saved);
                                    Fluttertoast.showToast(
                                      msg: _saved
                                          ? 'Added to favorites!'
                                          : 'Removed!',
                                    );
                                  },
                                  icon: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      _saved
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _saved
                                          ? Colors.red
                                          : AppColors.textDark,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Santorini, Greece',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.star,
                            size: 16,
                          ),
                          const Text(
                            ' 4.9 (1,248 Reviews)',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Oia',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'About Destination',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Experience breathtaking sunsets and iconic blue-domed churches in one of the most beautiful islands in the world. Enjoy luxury stays and Mediterranean cuisine with a panoramic view of the Aegean Sea.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Facilities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _facility(Icons.wifi, 'Free WiFi'),
                          _facility(Icons.pool, 'Pool'),
                          _facility(Icons.restaurant, 'Breakfast'),
                          _facility(Icons.spa, 'Spa'),
                          _facility(Icons.ac_unit, 'A/C'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Fluttertoast.showToast(msg: 'See All Photos'),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 90,
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
                      const SizedBox(height: 100),
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
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRICE',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const Text(
                        '\$450 / night',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(
                            hotel: HotelOffer(
                              name: 'Santorini Luxury Suite',
                              price: '450',
                              currency: 'USD',
                              hotelId: 'SAN123',
                            ),
                          ),
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _facility(IconData icon, String label) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
      ),
    ],
  );

 Widget _galleryImg(String url) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 90,
              height: 90,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
      );
}
