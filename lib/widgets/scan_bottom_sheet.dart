import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../services/nfc_service.dart';
import 'qr_scanner.dart';
import 'nfc_scanner.dart';

enum ScanMode { qr, nfc }

/// Layer: UI – Premium Bottom Sheet with Smooth Animations
class ScanBottomSheet extends StatefulWidget {
  const ScanBottomSheet({
    super.key,
    this.initialMode = ScanMode.qr,
    this.onScanSuccess,
    this.onCancel,
  });

  final ScanMode initialMode;
  final void Function(String type, String value)? onScanSuccess;
  final VoidCallback? onCancel;

  @override
  State<ScanBottomSheet> createState() => _ScanBottomSheetState();
}

class _ScanBottomSheetState extends State<ScanBottomSheet>
    with SingleTickerProviderStateMixin {
  late bool _isQrMode;
  bool _nfcSessionStarted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isQrMode = widget.initialMode == ScanMode.qr;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_nfcSessionStarted) {
      NfcService.stopSession();
    }
    super.dispose();
  }

  void _startNfcSession() {
    if (_nfcSessionStarted) return;
    _nfcSessionStarted = true;
    NfcService.startSession(
      onRead: (value) async {
        if (!mounted) return;
        try {
          await FirebaseService.saveScan(type: 'NFC', value: value);
          widget.onScanSuccess?.call('NFC', value);
          if (mounted) Navigator.of(context).pop();
        } catch (_) {}
      },
      onError: (msg) {
        if (mounted) _nfcSessionStarted = false;
      },
    );
  }

  void _onQrDetect(String value) async {
    try {
      await FirebaseService.saveScan(type: 'QR', value: value);
      widget.onScanSuccess?.call('QR', value);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {}
  }

  void _close() {
    if (_nfcSessionStarted) NfcService.stopSession();
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isQrMode && !_nfcSessionStarted) _startNfcSession();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Header with close button - เพิ่ม padding ด้านขวา
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'พร้อมที่',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              'จะสแกน',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _close,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Instruction text
                  Text(
                    _isQrMode
                        ? 'ชี้กล้องไปที่ QR Code เพื่อสแกน'
                        : 'Tap the card or ring as shown above\nand hold until the end of the operation.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Scanner area with card-like container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _isQrMode
                          ? QrScannerWidget(
                              key: const ValueKey('qr'),
                              onDetect: _onQrDetect,
                            )
                          : NfcScannerWidget(
                              key: const ValueKey('nfc'),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Mode toggle
                  Row(
                    children: [
                      Expanded(
                        child: _ModeButton(
                          label: 'QR',
                          isSelected: _isQrMode,
                          onTap: () {
                            if (_nfcSessionStarted) {
                              NfcService.stopSession();
                              _nfcSessionStarted = false;
                            }
                            setState(() => _isQrMode = true);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModeButton(
                          label: 'NFC',
                          isSelected: !_isQrMode,
                          onTap: () => setState(() => _isQrMode = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _close,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: AppTheme.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textPrimary : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.background : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// เปิด Bottom Sheet แบบ Smooth
void showScanBottomSheet(
  BuildContext context, {
  ScanMode initialMode = ScanMode.qr,
  void Function(String type, String value)? onScanSuccess,
  VoidCallback? onCancel,
}) {
  showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    expand: false,
    builder: (context) => ScanBottomSheet(
      initialMode: initialMode,
      onScanSuccess: onScanSuccess,
      onCancel: onCancel,
    ),
  );
}
