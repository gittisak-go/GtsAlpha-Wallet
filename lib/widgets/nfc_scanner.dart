import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Layer: UI – Minimalist NFC animation
class NfcScannerWidget extends StatefulWidget {
  const NfcScannerWidget({super.key});

  @override
  State<NfcScannerWidget> createState() => _NfcScannerWidgetState();
}

class _NfcScannerWidgetState extends State<NfcScannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(160, 160),
              painter: _NfcPainter(
                progress: _controller.value,
                color: AppTheme.primaryBlue,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NfcPainter extends CustomPainter {
  _NfcPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 8;

    // Animated rings
    for (int i = 0; i < 3; i++) {
      final t = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * (0.4 + t * 0.6);
      final opacity = (1 - t) * 0.4;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(center, radius, paint);
    }

    // Static ring
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, maxRadius, ringPaint);

    // Phone icon
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 40, height: 70),
      const Radius.circular(8),
    );
    
    canvas.drawRRect(
      phoneRect,
      Paint()..color = color.withOpacity(0.2)..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      phoneRect,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _NfcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
