import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';

/// Layer: UI – Minimalist QR Scanner
class QrScannerWidget extends StatefulWidget {
  const QrScannerWidget({
    super.key,
    required this.onDetect,
  });

  final void Function(String value) onDetect;

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasDetected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryMint.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_hasDetected) return;
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final value = barcode.rawValue;
                  if (value != null && value.isNotEmpty) {
                    _hasDetected = true;
                    widget.onDetect(value);
                    break;
                  }
                }
              },
              errorBuilder: (context, error, child) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'ไม่สามารถเปิดกล้องได้',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Corner frame overlay
            CustomPaint(
              size: const Size(double.infinity, 250),
              painter: _FramePainter(color: AppTheme.primaryMint),
            ),
            // Scanning line animation placeholder
            const _ScanningLine(),
          ],
        ),
      ),
    );
  }
}

class _ScanningLine extends StatefulWidget {
  const _ScanningLine();

  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 40 + (170 * _controller.value),
          left: 40,
          right: 40,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppTheme.primaryMint.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryMint.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLen = 30.0;
    final padding = 40.0;
    final rect = Rect.fromLTWH(
      padding, padding,
      size.width - padding * 2,
      size.height - padding * 2,
    );

    // Top-left
    canvas.drawLine(Offset(rect.left, rect.top + cornerLen), rect.topLeft, paint);
    canvas.drawLine(rect.topLeft, Offset(rect.left + cornerLen, rect.top), paint);

    // Top-right
    canvas.drawLine(Offset(rect.right - cornerLen, rect.top), rect.topRight, paint);
    canvas.drawLine(rect.topRight, Offset(rect.right, rect.top + cornerLen), paint);

    // Bottom-left
    canvas.drawLine(Offset(rect.left, rect.bottom - cornerLen), rect.bottomLeft, paint);
    canvas.drawLine(rect.bottomLeft, Offset(rect.left + cornerLen, rect.bottom), paint);

    // Bottom-right
    canvas.drawLine(Offset(rect.right - cornerLen, rect.bottom), rect.bottomRight, paint);
    canvas.drawLine(rect.bottomRight, Offset(rect.right, rect.bottom - cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
