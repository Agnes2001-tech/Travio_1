import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/amadeus_service.dart';
import '../models/flight_model.dart';
import '../models/hotel_model.dart';
import 'destination_details_screen.dart';
import 'booking_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AmadeusService _amadeusService = AmadeusService();
  final TextEditingController _hotelSearchController =
      TextEditingController(text: 'PAR');
  final TextEditingController _flightFromController =
      TextEditingController(text: 'LON');
  final TextEditingController _flightToController =
      TextEditingController(text: 'PAR');
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;
  List<FlightOffer> _flights = [];
  List<HotelOffer> _hotels = [];
  String _selectedCategory = 'Hotels';

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      if (_selectedCategory == 'Flights') _performSearch();
    }
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedCategory == 'Hotels') {
        final cityCode = _hotelSearchController.text.toUpperCase().trim();
        final results = await _amadeusService.searchHotels(cityCode: cityCode);
        setState(() {
          _hotels = results;
          _flights = [];
          _activities = [];
        });
      } else if (_selectedCategory == 'Flights') {
        final from = _flightFromController.text.toUpperCase().trim();
        final to = _flightToController.text.toUpperCase().trim();
        final results = await _amadeusService.searchFlights(
          origin: from,
          destination: to,
          departureDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        );
        setState(() {
          _flights = results;
          _hotels = [];
          _activities = [];
        });
      } else if (_selectedCategory == 'Places' || _selectedCategory == 'Packages') {
        final cityCode = _hotelSearchController.text.toUpperCase().trim();
        final coords = await _amadeusService.getCityCoordinates(cityCode.isEmpty ? 'PAR' : cityCode);
        if (_selectedCategory == 'Places') {
          final results = await _amadeusService.getPointsOfInterest(
            lat: coords['lat']!,
            lon: coords['lon']!,
          );
          setState(() {
            _activities = results;
            _hotels = [];
            _flights = [];
          });
        } else {
          final results = await _amadeusService.getToursAndActivities(
            lat: coords['lat']!,
            lon: coords['lon']!,
          );
          setState(() {
            _activities = results;
            _hotels = [];
            _flights = [];
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Search failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }
List<Map<String, dynamic>> _activities = [];

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
              child: (_selectedCategory == 'Hotels' || _selectedCategory == 'Places' || _selectedCategory == 'Packages')
                  ? TextField(
                      controller: _hotelSearchController,
                      onSubmitted: (_) => _performSearch(),
                      decoration: InputDecoration(
                        hintText: _selectedCategory == 'Hotels' 
                            ? 'Enter city code (e.g. PAR, LON)' 
                            : 'Enter city for ${_selectedCategory.toLowerCase()}',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _hotelSearchController.clear(),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _flightFromController,
                                decoration: const InputDecoration(
                                  hintText: 'From (NYC)',
                                  prefixIcon: Icon(Icons.flight_takeoff, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _flightToController,
                                decoration: const InputDecoration(
                                  hintText: 'To (LON)',
                                  prefixIcon: Icon(Icons.flight_land, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('EEE, d MMM yyyy').format(_selectedDate),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Spacer(),
                                const Text(
                                  'CHANGE',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _performSearch,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: const Text('Search Flights'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip('Hotels', _selectedCategory == 'Hotels'),
                  _filterChip('Flights', _selectedCategory == 'Flights'),
                  _filterChip('Places', _selectedCategory == 'Places'),
                  _filterChip('Packages', _selectedCategory == 'Packages'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedCategory == "Hotels" ? _hotels.length : _selectedCategory == "Flights" ? _flights.length : _activities.length} RESULTS FOUND',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Icon(Icons.map_outlined, color: AppColors.primary),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  Widget _buildHotelItem(HotelOffer hotel) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingScreen(hotel: hotel),
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
              child: Container(
                width: 100,
                height: 100,
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.hotel, color: AppColors.primary),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.textGrey,
                        ),
                        Text(
                          'Available now',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STARTING FROM',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              '${hotel.currency} ${hotel.price}/night',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(hotel: hotel),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(60, 30),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          child: const Text('Book'),
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingScreen(flight: flight),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.departureIata,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        DateFormat('HH:mm').format(flight.departureTime),
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Icon(Icons.flight_takeoff, color: AppColors.primary),
                      SizedBox(height: 4),
                      Text('Direct', style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        flight.arrivalIata,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        DateFormat('HH:mm').format(flight.arrivalTime),
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    flight.airline,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${flight.currency} ${flight.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final name = activity['name'] ?? 'Activity';
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
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.broken_image, color: AppColors.primary),
                ),
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
                  const Text(
                    'Explore now',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected) => GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
          if (label == 'Hotels' || label == 'Places' || label == 'Packages') {
            _performSearch();
          }
        },
        child: Container(
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
        ),
      );
}
