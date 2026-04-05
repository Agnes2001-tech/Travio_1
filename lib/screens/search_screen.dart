import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/amadeus_service.dart';
import '../services/favorites_service.dart';
import '../models/flight_model.dart';
import '../models/hotel_model.dart';
import '../widgets/glass_container.dart';
import '../widgets/stardust_background.dart';
import 'destination_details_screen.dart';
import 'booking_screen.dart';
import '../services/location_service.dart';

class SearchScreen extends StatefulWidget {
  static final GlobalKey<_SearchScreenState> searchKey = GlobalKey<_SearchScreenState>();
  const SearchScreen({super.key});

  static void setCategory(String category) {
    searchKey.currentState?.setState(() {
      searchKey.currentState?._selectedCategory = category;
      searchKey.currentState?._performSearch();
    });
  }

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AmadeusService _amadeusService = AmadeusService();
  final FavoritesService _favoritesService = FavoritesService();
  final LocationService _locationService = LocationService();
  
  late final TextEditingController _hotelSearchController;
  late final TextEditingController _flightFromController;
  late final TextEditingController _flightToController;
  
  String _selectedCategory = 'Flights';
  List<HotelOffer> _hotels = [];
  List<FlightOffer> _flights = [];
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _hotelSearchController = TextEditingController(text: 'BOM');
    _flightFromController = TextEditingController(text: 'BOM');
    _flightToController = TextEditingController(text: 'DXB');
    _performSearch();
  }

  @override
  void dispose() {
    _hotelSearchController.dispose();
    _flightFromController.dispose();
    _flightToController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.obsidianSecondary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
      if (_selectedCategory == 'Flights') _performSearch();
    }
  }

  Future<void> _handleCurrentLocation(TextEditingController controller) async {
    setState(() => _isLoading = true);
    final iataData = await _locationService.getIataFromCurrentLocation();
    if (iataData != null && mounted) {
      setState(() {
        controller.text = iataData['iataCode'] ?? '';
      });
      Fluttertoast.showToast(msg: 'Location updated: ${iataData['name']}');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _performSearch() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      if (_selectedCategory == 'Hotels') {
        final cityCode = _hotelSearchController.text.toUpperCase().trim();
        final results = await _amadeusService.searchHotels(cityCode: cityCode);
        if (mounted) {
          setState(() {
            _hotels = results;
            _flights = [];
            _activities = [];
          });
        }
      } else if (_selectedCategory == 'Flights') {
        final from = _flightFromController.text.toUpperCase().trim();
        final to = _flightToController.text.toUpperCase().trim();
        final results = await _amadeusService.searchFlights(
          origin: from,
          destination: to,
          departureDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        );
        if (mounted) {
          setState(() {
            _flights = results;
            _hotels = [];
            _activities = [];
          });
        }
      } else if (_selectedCategory == 'Places' || _selectedCategory == 'Packages') {
        final cityCode = _hotelSearchController.text.toUpperCase().trim();
        final coords = await _amadeusService.getCityCoordinates(cityCode.isEmpty ? 'BOM' : cityCode);
        if (_selectedCategory == 'Places') {
          final results = await _amadeusService.getPointsOfInterest(
            lat: coords['lat']!,
            lon: coords['lon']!,
          );
          if (mounted) {
            setState(() {
              _activities = results;
              _hotels = [];
              _flights = [];
            });
          }
        } else {
          final results = await _amadeusService.getToursAndActivities(
            lat: coords['lat']!,
            lon: coords['lon']!,
          );
          if (mounted) {
            setState(() {
              _activities = results;
              _hotels = [];
              _flights = [];
            });
          }
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Search unavailable for this location.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: StardustBackground(
        opacity: 0.05,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Row(
                  children: [
                    const BackButton(color: AppColors.textPrimary),
                    const Expanded(
                      child: Text(
                        'Exclusive Search',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    GlassContainer(
                      padding: const EdgeInsets.all(10),
                      borderRadius: 12,
                      child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: (_selectedCategory == 'Hotels' || _selectedCategory == 'Places' || _selectedCategory == 'Packages')
                    ? _buildGenericSearchField()
                    : _buildFlightSearchFields(),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _filterChip('Flights', _selectedCategory == 'Flights'),
                    _filterChip('Hotels', _selectedCategory == 'Hotels'),
                    _filterChip('Places', _selectedCategory == 'Places'),
                    _filterChip('Packages', _selectedCategory == 'Packages'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedCategory == "Hotels" ? _hotels.length : _selectedCategory == "Flights" ? _flights.length : _activities.length} Curated Results'.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 10, 
                        color: AppColors.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Icon(Icons.sort_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _selectedCategory == 'Hotels'
                            ? _hotels.length
                            : _selectedCategory == 'Flights'
                                ? _flights.length
                                : _activities.length,
                        itemBuilder: (_, i) {
                          if (_selectedCategory == 'Hotels') {
                            return _buildHotelItem(_hotels[i]);
                          } else if (_selectedCategory == 'Flights') {
                            return _buildFlightItem(_flights[i]);
                          } else {
                            return _buildActivityItem(_activities[i]);
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenericSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAirportAutocomplete(
          controller: _hotelSearchController,
          hintText: 'Enter City (e.g. BOM, LON, PAR)',
          icon: Icons.location_on_rounded,
        ),
         const SizedBox(height: 12),
        _buildPopularCitiesList(_hotelSearchController),
      ],
    );
  }

  Widget _buildFlightSearchFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAirportAutocomplete(
                controller: _flightFromController,
                hintText: 'From (BOM)',
                icon: Icons.flight_takeoff_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAirportAutocomplete(
                controller: _flightToController,
                hintText: 'To (DXB)',
                icon: Icons.flight_land_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('d MMM').format(_selectedDate),
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                   minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('SEARCH NOW'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPopularCitiesList(_flightToController),
      ],
    );
  }

  Widget _buildPopularCitiesList(TextEditingController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
           GestureDetector(
            onTap: () => _handleCurrentLocation(controller),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.my_location_rounded, size: 12, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('Current', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          ...LocationService.popularCities.map((city) {
            return GestureDetector(
              onTap: () {
                controller.text = city['code']!;
                _performSearch();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.obsidianTertiary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Text(city['name']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAirportAutocomplete({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) => option['iataCode'] ?? '',
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.length < 2) return const Iterable.empty();
        return await _amadeusService.searchAirports(textEditingValue.text);
      },
      onSelected: (selection) {
        controller.text = selection['iataCode'] ?? '';
        _performSearch();
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        fieldController.addListener(() {
          if (fieldController.text != controller.text) {
             controller.text = fieldController.text;
          }
        });
        
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          onSubmitted: (_) => onFieldSubmitted(),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: GlassContainer(
              margin: const EdgeInsets.only(top: 8),
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250, maxWidth: 320),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          option['subType'] == 'CITY' ? Icons.location_city : Icons.flight_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                      ),
                      title: Text(
                        '${option['name']} (${option['iataCode']})',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${option['address']?['cityName'] ?? ''}, ${option['address']?['countryCode'] ?? ''}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                      ),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHotelItem(HotelOffer hotel) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingScreen(hotel: hotel)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.obsidianSecondary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.obsidianTertiary,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
              ),
              child: const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 32),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hotel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            _favoritesService.isFavorite(hotel.hotelId) ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _favoritesService.toggleFavorite({
                                'id': hotel.hotelId,
                                'name': hotel.name,
                                'type': 'Hotel',
                                'price': hotel.price,
                                'currency': hotel.currency,
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                        const SizedBox(width: 4),
                        Text('Available', style: TextStyle(color: AppColors.success.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PRICE', style: TextStyle(fontSize: 9, color: AppColors.textGrey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            Text('${LocationService.currencySymbol} ${hotel.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)),
                          ],
                        ),
                        GlassContainer(
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: const Text('Book', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
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
    );
  }

  Widget _buildFlightItem(FlightOffer flight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.obsidianSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(flight.departureIata, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.textPrimary, letterSpacing: 1)),
                  Text(DateFormat('HH:mm').format(flight.departureTime), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.flight_takeoff_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(height: 4),
                    Container(
                      height: 1,
                      width: 60,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    const Text('Direct', style: TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(flight.arrivalIata, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.textPrimary, letterSpacing: 1)),
                  Text(DateFormat('HH:mm').format(flight.arrivalTime), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(flight.airline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('${LocationService.currencySymbol} ${flight.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(flight: flight))),
                    child: GlassContainer(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final name = activity['name'] ?? 'Activity';
    final pic = activity['pictures'] != null && (activity['pictures'] as List).isNotEmpty
        ? activity['pictures'][0]
        : 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=200';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DestinationDetailsScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.obsidianSecondary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                pic,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.obsidianTertiary,
                  child: const Icon(Icons.image_outlined, color: AppColors.textGrey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('EXPLORE NOW', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                _favoritesService.isFavorite(activity['id'].toString()) ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: Colors.redAccent,
              ),
              onPressed: () {
                setState(() {
                  _favoritesService.toggleFavorite({
                    'id': activity['id'],
                    'name': name,
                    'type': 'Activity',
                    'price': activity['price']?['amount'] ?? '0',
                    'currency': activity['price']?['currencyCode'] ?? 'EUR',
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected) => GestureDetector(
        onTap: () {
          setState(() => _selectedCategory = label);
          _performSearch();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.obsidianSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.primary : Colors.white.withOpacity(0.1)),
            boxShadow: selected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
}
