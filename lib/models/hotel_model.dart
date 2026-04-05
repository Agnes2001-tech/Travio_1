class HotelOffer {
  final String hotelId;
  final String name;
  final String price;
  final String currency;
  final String boardType;
  final String checkInDate;

  HotelOffer({
    required this.hotelId,
    required this.name,
    required this.price,
    required this.currency,
    required this.boardType,
    required this.checkInDate,
  });

  factory HotelOffer.fromJson(Map<String, dynamic> json) {
    final offer = json['offers'][0];
    return HotelOffer(
      hotelId: json['hotel']['hotelId'],
      name: json['hotel']['name'],
      price: offer['price']['total'],
      currency: offer['price']['currency'],
      boardType: offer['boardType'] ?? 'Room Only',
      checkInDate: offer['checkInDate'],
    );
  }
}
