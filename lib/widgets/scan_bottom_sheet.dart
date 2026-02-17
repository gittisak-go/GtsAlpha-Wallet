import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
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
          await SupabaseService.saveScanLog(type: 'NFC', value: value);
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
      await SupabaseService.saveScanLog(type: 'QR', value: value);
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
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'พร้อมสแกน',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _close,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
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
                  Text(
                    _isQrMode
                        ? 'วางรหัส QR ให้อยู่ในกรอบเพื่อเริ่มการสแกน'
                        : 'แตะการ์ดหรือแท็ก NFC ที่ด้านหลังโทรศัพท์ของคุณ',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Scanner Area
                  QrScannerWidget(
                    onDetect: _onQrDetect,
                  ),
                  const SizedBox(height: 32),
                  // Mode Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            label: 'QR Code',
                            isSelected: _isQrMode,
                            onTap: () => setState(() => _isQrMode = true),
                          ),
                        ),
                        Expanded(
                          child: _ModeButton(
                            label: 'NFC Tag',
                            isSelected: !_isQrMode,
                            onTap: () => setState(() => _isQrMode = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Cancel Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _close,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryMint,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryMint : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

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
