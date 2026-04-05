import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/flight_model.dart';
import '../models/hotel_model.dart';

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

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/v2/shopping/flight-offers?originLocationCode=$origin&destinationLocationCode=$destination&departureDate=$departureDate&adults=$adults&max=10',
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
    int adults = 1,
  }) async {
    final token = await _getAccessToken();

    // Step 1: Get hotel list for city
    final listResponse = await http.get(
      Uri.parse(
        '$_baseUrl/v1/reference-data/locations/hotels/by-city?cityCode=$cityCode&radius=5&radiusUnit=KM&hotelSource=ALL',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (listResponse.statusCode != 200) {
      throw Exception('Failed to get hotel list: ${listResponse.body}');
    }

    final listData = json.decode(listResponse.body);
    final hotelIds = (listData['data'] as List)
        .take(5) // Limit to 5 hotels for faster search in test env
        .map((h) => h['hotelId'])
        .join(',');

    if (hotelIds.isEmpty) return [];

    // Step 2: Get real-time offers for those hotels
    final offersResponse = await http.get(
      Uri.parse(
        '$_baseUrl/v3/shopping/hotel-offers?hotelIds=$hotelIds&adults=$adults',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (offersResponse.statusCode == 200) {
      final offersData = json.decode(offersResponse.body);
      return (offersData['data'] as List)
          .map((item) => HotelOffer.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to search hotels: ${offersResponse.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getPointsOfInterest(
      {required double lat, required double lon}) async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/reference-data/locations/pois?latitude=$lat&longitude=$lon&radius=5'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to fetch POIs: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getToursAndActivities(
      {required double lat, required double lon}) async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/shopping/activities?latitude=$lat&longitude=$lon&radius=5'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to fetch activities: ${response.body}');
    }
  }

  Future<Map<String, double>> getCityCoordinates(String cityCode) async {
    // Static coordinates for common test cities to avoid complexity
    const cityMap = {
      'PAR': {'lat': 48.864716, 'lon': 2.349014},
      'LON': {'lat': 51.5074, 'lon': -0.1278},
      'NYC': {'lat': 40.7128, 'lon': -74.0060},
      'TYO': {'lat': 35.6762, 'lon': 139.6503},
    };
    return cityMap[cityCode] ?? cityMap['PAR']!;
  }
}
