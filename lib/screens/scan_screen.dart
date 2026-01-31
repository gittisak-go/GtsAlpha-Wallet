import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/scan_bottom_sheet.dart';

/// Layer: UI – Minimalist Dark UI แบบ Tangem
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // GtsAlpha Wallet Title with Glow Effect
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlueLight,
                    AppTheme.primaryBlue,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Stack(
                  children: [
                    // Glow effect
                    Text(
                      'GtsAlpha Wallet',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.8,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: AppTheme.primaryBlue.withOpacity(0.8),
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                          Shadow(
                            color: AppTheme.primaryBlue.withOpacity(0.6),
                            blurRadius: 40,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    // Main text
                    Text(
                      'GtsAlpha Wallet',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Subtitle
              Text(
                'แตะการ์ดหรือสแกน QR Code\nเพื่อเริ่มต้นใช้งาน',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(flex: 3),
              // Bottom Buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Scan QR',
                      icon: Icons.qr_code_scanner_rounded,
                      isPrimary: true,
                      onTap: () => _showScanner(context, isQrMode: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'Tap NFC',
                      icon: Icons.nfc_rounded,
                      isPrimary: false,
                      onTap: () => _showScanner(context, isQrMode: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanner(BuildContext context, {required bool isQrMode}) {
    showScanBottomSheet(
      context,
      initialMode: isQrMode ? ScanMode.qr : ScanMode.nfc,
      onScanSuccess: (type, value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type: $value'),
            backgroundColor: AppTheme.primaryBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.textPrimary : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? AppTheme.background : AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              icon,
              size: 20,
              color: isPrimary ? AppTheme.background : AppTheme.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
