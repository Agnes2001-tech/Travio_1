import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  final _places = const [
    {
      'name': 'Santorini, Greece',
      'price': 'From \$1,240',
      'img':
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=400',
    },
    {
      'name': 'Kyoto, Japan',
      'price': 'From \$890',
      'img':
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
    },
    {
      'name': 'Swiss Alps',
      'price': 'From \$2,100',
      'img':
          'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=400',
    },
    {
      'name': 'Bali, Indonesia',
      'price': 'From \$650',
      'img':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
    },
    {
      'name': 'Paris, France',
      'price': 'From \$1,550',
      'img':
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
    },
    {
      'name': 'Dubai, UAE',
      'price': 'From \$1,100',
      'img':
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.tune), onPressed: () {})],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _tab('All', true),
                _tab('Hotels', false),
                _tab('Flights', false),
                _tab('Trips', false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '12 items saved',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                TextButton(
                  onPressed: () => Fluttertoast.showToast(msg: 'Edit mode'),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _places.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => Fluttertoast.showToast(msg: _places[i]['name']!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Image.network(
                        _places[i]['img']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _places[i]['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _places[i]['price']!,
                              style: const TextStyle(
                                color: Colors.lightBlueAccent,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool selected) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.textGrey,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ),
  );
}
