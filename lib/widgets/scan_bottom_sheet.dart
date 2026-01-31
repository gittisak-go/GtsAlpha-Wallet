import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../services/nfc_service.dart';
import 'qr_scanner.dart';
import 'nfc_scanner.dart';

enum ScanMode { qr, nfc }

/// Layer: UI – Minimalist Bottom Sheet
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

class _ScanBottomSheetState extends State<ScanBottomSheet> {
  late bool _isQrMode;
  bool _nfcSessionStarted = false;

  @override
  void initState() {
    super.initState();
    _isQrMode = widget.initialMode == ScanMode.qr;
  }

  @override
  void dispose() {
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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            // Header with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    _isQrMode ? 'Scan QR' : 'Tap NFC',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _close,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Scanner area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isQrMode
                  ? QrScannerWidget(onDetect: _onQrDetect)
                  : const NfcScannerWidget(),
            ),
            const SizedBox(height: 20),
            // Mode toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeButton(
                      label: 'NFC',
                      isSelected: !_isQrMode,
                      onTap: () => setState(() => _isQrMode = false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
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
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textPrimary : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
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

/// เปิด Bottom Sheet
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
