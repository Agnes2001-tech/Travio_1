import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'amadeus_service.dart';

class LocationData {
  final String name;
  final String cityCode;
  final double lat;
  final double lon;

  const LocationData({
    required this.name,
    required this.cityCode,
    required this.lat,
    required this.lon,
  });
}

class LocationService {
  final AmadeusService _amadeusService = AmadeusService();

  // Observable for current active destination
  final ValueNotifier<LocationData> currentLocation = ValueNotifier<LocationData>(
    const LocationData(name: 'Mumbai', cityCode: 'BOM', lat: 19.0760, lon: 72.8777),
  );

  static const String defaultCurrency = 'INR';
  static const String currencySymbol = '₹';

  static const List<LocationData> availableCities = [
    LocationData(name: 'Mumbai', cityCode: 'BOM', lat: 19.0760, lon: 72.8777),
    LocationData(name: 'Delhi', cityCode: 'DEL', lat: 28.6139, lon: 77.2090),
    LocationData(name: 'Bangalore', cityCode: 'BLR', lat: 12.9716, lon: 77.5946),
    LocationData(name: 'Goa', cityCode: 'GOI', lat: 15.2993, lon: 74.1240),
    LocationData(name: 'Udaipur', cityCode: 'UDR', lat: 24.5854, lon: 73.7124),
    LocationData(name: 'Srinagar', cityCode: 'SXR', lat: 34.0837, lon: 74.7973),
    LocationData(name: 'London', cityCode: 'LON', lat: 51.5074, lon: -0.1278),
    LocationData(name: 'Paris', cityCode: 'PAR', lat: 48.8566, lon: 2.3522),
    LocationData(name: 'New York', cityCode: 'NYC', lat: 40.7128, lon: -74.0060),
    LocationData(name: 'Tokyo', cityCode: 'TYO', lat: 35.6762, lon: 139.6503),
    LocationData(name: 'Dubai', cityCode: 'DXB', lat: 25.2048, lon: 55.2708),
    LocationData(name: 'Singapore', cityCode: 'SIN', lat: 1.3521, lon: 103.8198),
    LocationData(name: 'Santorini', cityCode: 'JTR', lat: 36.3932, lon: 25.4615),
    LocationData(name: 'Maldives', cityCode: 'MLE', lat: 4.1755, lon: 73.5093),
    LocationData(name: 'Bali', cityCode: 'DPS', lat: -8.4095, lon: 115.1889),
    LocationData(name: 'Rome', cityCode: 'FCO', lat: 41.9028, lon: 12.4964),
    LocationData(name: 'Barcelona', cityCode: 'BCN', lat: 41.3851, lon: 2.1734),
    LocationData(name: 'Venice', cityCode: 'VCE', lat: 45.4408, lon: 12.3155),
    LocationData(name: 'Swiss Alps', cityCode: 'ZRH', lat: 47.3769, lon: 8.5417),
    LocationData(name: 'Amsterdam', cityCode: 'AMS', lat: 52.3676, lon: 4.9041),
    LocationData(name: 'Prague', cityCode: 'PRG', lat: 50.0755, lon: 14.4378),
    LocationData(name: 'Vienna', cityCode: 'VIE', lat: 48.2082, lon: 16.3738),
    LocationData(name: 'Lisbon', cityCode: 'LIS', lat: 38.7223, lon: -9.1393),
    LocationData(name: 'Madrid', cityCode: 'MAD', lat: 40.4168, lon: -3.7038),
    LocationData(name: 'Athens', cityCode: 'ATH', lat: 37.9838, lon: 23.7275),
    LocationData(name: 'Istanbul', cityCode: 'IST', lat: 41.0082, lon: 28.9784),
    LocationData(name: 'Cairo', cityCode: 'CAI', lat: 30.0444, lon: 31.2357),
    LocationData(name: 'Cape Town', cityCode: 'CPT', lat: -33.9249, lon: 18.4241),
    LocationData(name: 'Marrakech', cityCode: 'RAK', lat: 31.6295, lon: -7.9811),
    LocationData(name: 'Seychelles', cityCode: 'SEZ', lat: -4.6796, lon: 55.4920),
    LocationData(name: 'Mauritius', cityCode: 'MRU', lat: -20.3484, lon: 57.5522),
    LocationData(name: 'Sydney', cityCode: 'SYD', lat: -33.8688, lon: 151.2093),
    LocationData(name: 'Rio de Janeiro', cityCode: 'GIG', lat: -22.9068, lon: -43.1729),
    LocationData(name: 'Buenos Aires', cityCode: 'EZE', lat: -34.6037, lon: -58.3816),
    LocationData(name: 'Cancun', cityCode: 'CUN', lat: 21.1619, lon: -86.8515),
    LocationData(name: 'Mexico City', cityCode: 'MEX', lat: 19.4326, lon: -99.1332),
    LocationData(name: 'Machu Picchu', cityCode: 'CUZ', lat: -13.5319, lon: -71.9675),
    LocationData(name: 'Los Angeles', cityCode: 'LAX', lat: 34.0522, lon: -118.2437),
    LocationData(name: 'San Francisco', cityCode: 'SFO', lat: 37.7749, lon: -122.4194),
    LocationData(name: 'Las Vegas', cityCode: 'LAS', lat: 36.1716, lon: -115.1391),
    LocationData(name: 'Miami', cityCode: 'MIA', lat: 25.7617, lon: -80.1918),
    LocationData(name: 'Honolulu', cityCode: 'HNL', lat: 21.3069, lon: -157.8583),
    LocationData(name: 'Seoul', cityCode: 'ICN', lat: 37.5665, lon: 126.9780),
    LocationData(name: 'Hong Kong', cityCode: 'HKG', lat: 22.3193, lon: 114.1694),
    LocationData(name: 'Bangkok', cityCode: 'BKK', lat: 13.7563, lon: 100.5018),
    LocationData(name: 'Phuket', cityCode: 'HKT', lat: 7.8804, lon: 98.3923),
    LocationData(name: 'Munich', cityCode: 'MUC', lat: 48.1351, lon: 11.5820),
    LocationData(name: 'Berlin', cityCode: 'BER', lat: 52.5200, lon: 13.4050),
    LocationData(name: 'Toronto', cityCode: 'YYZ', lat: 43.6532, lon: -79.3832),
    LocationData(name: 'Vancouver', cityCode: 'YVR', lat: 49.2827, lon: -123.1207),
  ];

  static const List<Map<String, String>> popularCities = [
    {'name': 'Mumbai', 'code': 'BOM', 'country': 'India'},
    {'name': 'London', 'code': 'LON', 'country': 'UK'},
    {'name': 'Paris', 'code': 'PAR', 'country': 'France'},
    {'name': 'Dubai', 'code': 'DXB', 'country': 'UAE'},
  ];

  void updateLocation(LocationData data) {
    currentLocation.value = data;
  }

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Location permissions are permanently denied.');
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>?> getIataFromCurrentLocation() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    final results = await _amadeusService.searchAirportsByCoords(
      lat: position.latitude,
      lon: position.longitude,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
