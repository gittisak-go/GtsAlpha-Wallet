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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final value = barcode.rawValue;
                  if (value != null && value.isNotEmpty) {
                    widget.onDetect(value);
                    break;
                  }
                }
              },
            ),
            // Corner frame overlay
            CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _FramePainter(color: AppTheme.primaryBlue),
            ),
          ],
        ),
      ),
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
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cornerLen = 24.0;
    final padding = 30.0;
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
