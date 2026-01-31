import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Layer: UI – Premium NFC Scanner with Visual Feedback
class NfcScannerWidget extends StatefulWidget {
  const NfcScannerWidget({super.key});

  @override
  State<NfcScannerWidget> createState() => _NfcScannerWidgetState();
}

class _NfcScannerWidgetState extends State<NfcScannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(180, 180),
              painter: _PremiumNfcPainter(
                progress: _ringAnimation.value,
                pulseProgress: _pulseAnimation.value,
                color: AppTheme.primaryBlue,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumNfcPainter extends CustomPainter {
  _PremiumNfcPainter({
    required this.progress,
    required this.pulseProgress,
    required this.color,
  });

  final double progress;
  final double pulseProgress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 8;

    // Outer static ring - เครื่องหมายยืนยันการสแกน
    final outerRingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, maxRadius, outerRingPaint);

    // Animated expanding rings - เรืองแสง
    for (int i = 0; i < 3; i++) {
      final t = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * (0.4 + t * 0.6);
      final opacity = (1 - t) * 0.4;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      
      canvas.drawCircle(center, radius, paint);
    }

    // Inner glow pulse - เรืองแสงภายใน
    final innerGlowPaint = Paint()
      ..color = color.withOpacity(0.15 + pulseProgress * 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.65, innerGlowPaint);

    // Phone icon - รูปโทรศัพท์
    _drawPhone(canvas, center, color);
  }

  void _drawPhone(Canvas canvas, Offset center, Color color) {
    final phoneWidth = 44.0;
    final phoneHeight = 76.0;
    final cornerRadius = 10.0;

    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: phoneWidth, height: phoneHeight),
      Radius.circular(cornerRadius),
    );

    // Phone fill with gradient effect
    final phoneFillPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(phoneRect, phoneFillPaint);

    // Phone border - เส้นขอบสีฟ้า
    final phoneBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(phoneRect, phoneBorderPaint);

    // Screen area
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 6),
        width: phoneWidth - 10,
        height: phoneHeight - 28,
      ),
      Radius.circular(cornerRadius - 3),
    );
    final screenPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(screenRect, screenPaint);

    // Home indicator / bottom bar
    final bottomBarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + phoneHeight / 2 - 12),
        width: 24,
        height: 4,
      ),
      const Radius.circular(2),
    );
    final bottomBarPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bottomBarRect, bottomBarPaint);
  }

  @override
  bool shouldRepaint(covariant _PremiumNfcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}
