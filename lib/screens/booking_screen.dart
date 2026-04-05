import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import '../models/flight_model.dart';
import '../models/hotel_model.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final FlightOffer? flight;
  final HotelOffer? hotel;

  const BookingScreen({super.key, this.flight, this.hotel});
  
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _guests = 2;

  String _getName() {
    if (widget.flight != null) {
      return 'Flight ${widget.flight!.airline} (${widget.flight!.departureIata}-${widget.flight!.arrivalIata})';
    } else if (widget.hotel != null) {
      return widget.hotel!.name;
    }
    return 'Premium Package';
  }

  String _getPrice() => widget.flight?.price ?? (widget.hotel?.price ?? '0');
  String _getCurrency() => widget.flight?.currency ?? (widget.hotel?.currency ?? 'USD');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Your Booking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.flight != null 
                        ? 'https://images.unsplash.com/photo-1436491865332-7a61a109c055?w=200' 
                        : 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=200',
                      width: 70, height: 70, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getName(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          widget.flight != null 
                            ? 'Economy Class • Non-stop' 
                            : 'Luxury Suite • Ocean View',
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                        ),
                        Text(
                          '${_getPrice()} ${_getCurrency()}',
                          style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('GUESTS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textGrey, letterSpacing: 1)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.group_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Number of Travelers', style: TextStyle(fontWeight: FontWeight.w600))),
                  IconButton(
                    onPressed: () => setState(() { if (_guests > 1) _guests--; }),
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                  ),
                  Text('$_guests', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => setState(() => _guests++),
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('PRICE BREAKDOWN', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textGrey, letterSpacing: 1)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  _priceRow('Base Fare', '${_getPrice()} ${_getCurrency()}'),
                  _priceRow('Taxes & Insurance', '12.00 ${_getCurrency()}'),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${(double.parse(_getPrice()) + 12).toStringAsFixed(2)} ${_getCurrency()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      bookingDetails: {
                        'name': _getName(),
                        'amount': (double.parse(_getPrice()) + 12).toStringAsFixed(2),
                        'currency': _getCurrency(),
                        'ref': 'TRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      },
                    ),
                  ),
                );
              },
              child: const Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
