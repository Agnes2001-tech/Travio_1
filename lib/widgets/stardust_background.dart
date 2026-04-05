import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StardustBackground extends StatelessWidget {
  final Widget child;
  final double opacity;

  const StardustBackground({
    super.key,
    required this.child,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _NoisePainter(opacity: opacity),
          ),
        ),
        child,
      ],
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double opacity;
  final Random _random = Random(42); // Seed for consistency

  _NoisePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1.0;

    // Draw ~1000 tiny dots at random positions
    for (int i = 0; i < 1500; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 0.8;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
