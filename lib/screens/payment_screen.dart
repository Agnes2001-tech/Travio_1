import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import 'booking_status_screen.dart';
import '../widgets/glass_container.dart';
import '../widgets/stardust_background.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const PaymentScreen({super.key, required this.bookingDetails});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  
  bool _isProcessing = false;

  bool _isLuhnValid(String cardNumber) {
    String digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;
    
    int sum = 0;
    bool isSecond = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int d = int.parse(digits[i]);
      if (isSecond) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      isSecond = !isSecond;
    }
    return sum % 10 == 0;
  }

  void _processPayment() async {
    final cardNumber = _cardController.text.trim();
    if (cardNumber.isEmpty) {
        Fluttertoast.showToast(msg: 'Please enter card number');
        return;
    }
    if (!_isLuhnValid(cardNumber)) {
      Fluttertoast.showToast(
        msg: 'Invalid card number (Luhn Check Failed)',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate processing

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingStatusScreen(bookingDetails: widget.bookingDetails),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const Text('Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: StardustBackground(
        opacity: 0.03,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PAYMENT SUMMARY',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.bookingDetails['name'] ?? 'Flight Booking', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    Text(
                      '${LocationService.currencySymbol} ${widget.bookingDetails['amount']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'CREDIT CARD',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cardController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Card Number (e.g., 4242 4242 4242 4242)',
                  prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'CVV',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Secure Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security_rounded, size: 16, color: AppColors.success.withOpacity(0.8)),
                  const SizedBox(width: 8),
                  Text(
                    'Your payment is encrypted and secure.',
                    style: TextStyle(fontSize: 12, color: AppColors.success.withOpacity(0.8), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
