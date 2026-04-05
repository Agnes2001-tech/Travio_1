class FlightOffer {
  final String id;
  final String airline;
  final String departureIata;
  final String arrivalIata;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String price;
  final String currency;
  final String numberOfStops;

  FlightOffer({
    required this.id,
    required this.airline,
    required this.departureIata,
    required this.arrivalIata,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.currency,
    required this.numberOfStops,
  });

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    final itinerary = json['itineraries'][0];
    final segment = itinerary['segments'][0];
    final arrivalSegment = itinerary['segments'].last;

    return FlightOffer(
      id: json['id'],
      airline: json['validatingAirlineCodes'][0],
      departureIata: segment['departure']['iataCode'],
      arrivalIata: arrivalSegment['arrival']['iataCode'],
      departureTime: DateTime.parse(segment['departure']['at']),
      arrivalTime: DateTime.parse(arrivalSegment['arrival']['at']),
      price: json['price']['total'],
      currency: json['price']['currency'],
      numberOfStops: (itinerary['segments'].length - 1).toString(),
    );
  }
}
