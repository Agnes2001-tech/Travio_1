import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import 'destination_details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  final _hotels = const [
    {
      'name': 'Hôtel Plaza Athénée',
      'loc': '8th Arr., Paris',
      'price': '\$840',
      'rating': '4.9',
    },
    {
      'name': 'Le Bristol Paris',
      'loc': 'Rue du Faubourg, Paris',
      'price': '\$1,250',
      'rating': '4.8',
    },
    {
      'name': 'Shangri-La Hotel',
      'loc': 'Trocadéro, Paris',
      'price': '\$980',
      'rating': '4.7',
    },
    {
      'name': 'Hotel Lutetia',
      'loc': 'Saint-Germain, Paris',
      'price': '\$620',
      'rating': '4.9',
    },
  ];

  final _imgs = const [
    'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=200',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200',
    'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=200',
    'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=200',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const BackButton(),
                  const Expanded(
                    child: Text(
                      'Search Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Paris, France',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.close),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip('Hotels', true),
                  _filterChip('Flights', false),
                  _filterChip('Price: Low-High', false),
                  _filterChip('Rating', false),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '142 PROPERTIES FOUND',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Icon(Icons.map_outlined, color: AppColors.primary),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 4,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DestinationDetailsScreen(),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(14),
                          ),
                          child: Image.network(
                            _imgs[i],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _hotels[i]['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: AppColors.textGrey,
                                    ),
                                    Text(
                                      _hotels[i]['loc']!,
                                      style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'STARTING FROM',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                        Text(
                                          '${_hotels[i]['price']}/night',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Fluttertoast.showToast(
                                        msg: 'Details tapped',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(60, 30),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                      ),
                                      child: const Text(
                                        'Details',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: selected ? Colors.white : AppColors.textGrey,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
