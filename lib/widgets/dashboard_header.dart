import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onScanTap;

  const DashboardHeader({
    super.key,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Weather/Status Bar
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_rounded, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '28°C',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Main QR Scanner Icon
        GestureDetector(
          onTap: onScanTap,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryMint.withOpacity(0.3),
                width: 12,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryMint,
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Main Action Button
        GestureDetector(
          onTap: onScanTap,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryMint,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text(
                'สแกนรหัส qr',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
