import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/flight_model.dart';
import '../models/hotel_model.dart';
import 'location_service.dart';

class AmadeusService {
  static const String _baseUrl = 'https://test.api.amadeus.com';
  String? _accessToken;
  DateTime? _tokenExpiry;

  Future<String> _getAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    final String apiKey = dotenv.get('AMADEUS_API_KEY');
    final String apiSecret = dotenv.get('AMADEUS_API_SECRET');

    final response = await http.post(
      Uri.parse('$_baseUrl/v1/security/oauth2/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': apiKey,
        'client_secret': apiSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _tokenExpiry =
          DateTime.now().add(Duration(seconds: data['expires_in'] - 60));
      return _accessToken!;
    } else {
      throw Exception('Failed to get Amadeus access token: ${response.body}');
    }
  }

  Future<List<FlightOffer>> searchFlights({
    required String origin,
    required String destination,
    required String departureDate,
    int adults = 1,
  }) async {
    final token = await _getAccessToken();
    // Adding currencyCode=INR for flight search
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/v2/shopping/flight-offers?originLocationCode=$origin&destinationLocationCode=$destination&departureDate=$departureDate&adults=$adults&max=10&currencyCode=${LocationService.defaultCurrency}',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((item) => FlightOffer.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to search flights: ${response.body}');
    }
  }

  Future<List<HotelOffer>> searchHotels({
    required String cityCode,
    String? checkInDate,
    String? checkOutDate,
    int adults = 1,
  }) async {
    final token = await _getAccessToken();

    final checkIn = checkInDate ??
        DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7)));
    final checkOut = checkOutDate ??
        DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 8)));

    final listResponse = await http.get(
      Uri.parse('$_baseUrl/v1/reference-data/locations/hotels/by-city?cityCode=$cityCode&radius=5&radiusUnit=KM'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (listResponse.statusCode != 200) return [];

    final listData = json.decode(listResponse.body);
    final List data = listData['data'] ?? [];
    if (data.isEmpty) return [];

    final hotelIds = data.take(5).map((h) => h['hotelId']).join(',');

    try {
      // Adding currency=INR for hotel search
      final offersResponse = await http.get(
        Uri.parse('$_baseUrl/v3/shopping/hotel-offers?hotelIds=$hotelIds&adults=$adults&checkInDate=$checkIn&checkOutDate=$checkOut&currency=${LocationService.defaultCurrency}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (offersResponse.statusCode == 200) {
        final offersData = json.decode(offersResponse.body);
        return (offersData['data'] as List)
            .map((item) => HotelOffer.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchAirports(String query) async {
    if (query.trim().length < 2) return [];
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/reference-data/locations?subType=CITY,AIRPORT&keyword=$query&page[limit]=5'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> searchAirportsByCoords({required double lat, required double lon}) async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/reference-data/locations/airports?latitude=$lat&longitude=$lon&radius=50&page[limit]=5'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getPointsOfInterest({required double lat, required double lon}) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/reference-data/locations/pois?latitude=$lat&longitude=$lon&radius=5&page[limit]=10'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      print('Amadeus POI Error: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getToursAndActivities({required double lat, required double lon}) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/shopping/activities?latitude=$lat&longitude=$lon&radius=5'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
        print('Amadeus Tours Error: $e');
    }
    return [];
  }

  Future<String> getAirportName(String iataCode) async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/reference-data/locations?subType=CITY,AIRPORT&keyword=$iataCode&page[limit]=1'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if ((data['data'] as List).isNotEmpty) {
        return data['data'][0]['name'];
      }
    }
    return iataCode;
  }

  Future<Map<String, double>> getCityCoordinates(String cityCode) async {
    // Coordinate mapping expansion for 50+ hubs
    final cityMap = <String, Map<String, double>>{
      'BOM': {'lat': 19.0760, 'lon': 72.8777},
      'DEL': {'lat': 28.6139, 'lon': 77.2090},
      'BLR': {'lat': 12.9716, 'lon': 77.5946},
      'GOI': {'lat': 15.2993, 'lon': 74.1240},
      'UDR': {'lat': 24.5854, 'lon': 73.7124},
      'SXR': {'lat': 34.0837, 'lon': 74.7973},
      'LON': {'lat': 51.5074, 'lon': -0.1278},
      'PAR': {'lat': 48.8566, 'lon': 2.3522},
      'NYC': {'lat': 40.7128, 'lon': -74.0060},
      'TYO': {'lat': 35.6762, 'lon': 139.6503},
      'DXB': {'lat': 25.2048, 'lon': 55.2708},
      'SIN': {'lat': 1.3521, 'lon': 103.8198},
      'JTR': {'lat': 36.3932, 'lon': 25.4615},
      'MLE': {'lat': 4.1755, 'lon': 73.5093},
      'DPS': {'lat': -8.4095, 'lon': 115.1889},
      'FCO': {'lat': 41.9028, 'lon': 12.4964},
      'BCN': {'lat': 41.3851, 'lon': 2.1734},
      'VCE': {'lat': 45.4408, 'lon': 12.3155},
      'ZRH': {'lat': 47.3769, 'lon': 8.5417},
      'AMS': {'lat': 52.3676, 'lon': 4.9041},
      'PRG': {'lat': 50.0755, 'lon': 14.4378},
      'VIE': {'lat': 48.2082, 'lon': 16.3738},
      'LIS': {'lat': 38.7223, 'lon': -9.1393},
      'MAD': {'lat': 40.4168, 'lon': -3.7038},
      'ATH': {'lat': 37.9838, 'lon': 23.7275},
      'IST': {'lat': 41.0082, 'lon': 28.9784},
      'CAI': {'lat': 30.0444, 'lon': 31.2357},
      'CPT': {'lat': -33.9249, 'lon': 18.4241},
      'RAK': {'lat': 31.6295, 'lon': -7.9811},
      'SEZ': {'lat': -4.6796, 'lon': 55.4920},
      'MRU': {'lat': -20.3484, 'lon': 57.5522},
      'SYD': {'lat': -33.8688, 'lon': 151.2093},
      'GIG': {'lat': -22.9068, 'lon': -43.1729},
      'EZE': {'lat': -34.6037, 'lon': -58.3816},
      'CUN': {'lat': 21.1619, 'lon': -86.8515},
      'MEX': {'lat': 19.4326, 'lon': -99.1332},
      'CUZ': {'lat': -13.5319, 'lon': -71.9675},
      'LAX': {'lat': 34.0522, 'lon': -118.2437},
      'SFO': {'lat': 37.7749, 'lon': -122.4194},
      'LAS': {'lat': 36.1716, 'lon': -115.1391},
      'MIA': {'lat': 25.7617, 'lon': -80.1918},
      'HNL': {'lat': 21.3069, 'lon': -157.8583},
      'ICN': {'lat': 37.5665, 'lon': 126.9780},
      'HKG': {'lat': 22.3193, 'lon': 114.1694},
      'BKK': {'lat': 13.7563, 'lon': 100.5018},
      'HKT': {'lat': 7.8804, 'lon': 98.3923},
      'MUC': {'lat': 48.1351, 'lon': 11.5820},
      'BER': {'lat': 52.5200, 'lon': 13.4050},
      'YYZ': {'lat': 43.6532, 'lon': -79.3832},
      'YVR': {'lat': 49.2827, 'lon': -123.1207},
    };
    return cityMap[cityCode] ?? cityMap['BOM']!;
  }
}
