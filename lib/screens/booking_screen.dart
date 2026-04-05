import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/flight_model.dart';
import '../models/hotel_model.dart';
import 'payment_screen.dart';
import '../widgets/glass_container.dart';
import '../widgets/stardust_background.dart';

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
  String _getCurrency() => widget.flight?.currency ?? (widget.hotel?.currency ?? LocationService.defaultCurrency);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const Text('Confirm Your Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: StardustBackground(
        opacity: 0.03,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 24,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.flight != null 
                          ? 'https://images.unsplash.com/photo-1436491865332-7a61a109c055?w=200' 
                          : 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=200',
                        width: 80, height: 80, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getName(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            widget.flight != null 
                              ? 'Economy Class • Non-stop' 
                              : 'Luxury Suite • Ocean View',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${LocationService.currencySymbol} ${_getPrice()}',
                            style: const TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('GUESTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textGrey, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 20,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.group_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text('Total Travelers', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                    GestureDetector(
                      onTap: () => setState(() { if (_guests > 1) _guests--; }),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(8),
                        borderRadius: 10,
                        child: const Icon(Icons.remove_rounded, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_guests', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _guests++),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(8),
                        borderRadius: 10,
                        child: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('PRICE BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textGrey, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Column(
                  children: [
                    _priceRow('Base Fare', '${LocationService.currencySymbol} ${_getPrice()}'),
                    _priceRow('Travelers', 'x $_guests'),
                    _priceRow('Taxes & Insurance', '${LocationService.currencySymbol} 1250.00'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white.withOpacity(0.05)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15)),
                        Text(
                          '${LocationService.currencySymbol} ${(double.parse(_getPrice()) * _guests + 1250).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          bookingDetails: {
                            'name': _getName(),
                            'amount': (double.parse(_getPrice()) * _guests + 1250).toStringAsFixed(2),
                            'currency': _getCurrency(),
                            'ref': 'TRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    ),
  );
}
