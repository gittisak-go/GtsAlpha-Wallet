import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/grid_menu.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/scan_bottom_sheet.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  int _currentIndex = 0;

  void _openScanner(String type) {
    showScanBottomSheet(
      context,
      initialMode: ScanMode.qr,
      onScanSuccess: (scanType, value) {
        _handleScanResult(type, value);
      },
    );
  }

  void _handleScanResult(String type, String value) {
    // แสดงผลลัพธ์การสแกนผ่าน SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สแกน $type สำเร็จ!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('ข้อมูล: $value'),
          ],
        ),
        backgroundColor: AppTheme.primaryMint,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'ตกลง',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                DashboardHeader(
                  onScanTap: () => _openScanner('QR Code'),
                ),
                const SizedBox(height: 40),
                GridMenu(
                  onItemTap: (title) => _openScanner(title),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
