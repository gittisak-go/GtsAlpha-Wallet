import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Layer: Service – บันทึก log การสแกน
/// ใช้ Supabase เมื่อเชื่อมต่อได้ มิฉะนั้น print ลง console
class FirebaseService {
  static bool get isAvailable => true;

  static Future<void> ensureInitialized() async {
    await SupabaseService.initialize();
  }

  /// บันทึกการสแกน (QR หรือ NFC) – Supabase หรือ console
  static Future<void> saveScan({
    required String type,
    required String value,
    String? deviceId,
  }) async {
    if (SupabaseService.isAvailable) {
      try {
        await SupabaseService.saveScanLog(
          type: type,
          value: value,
          deviceId: deviceId,
        );
        return;
      } catch (_) {
        debugPrint('📱 Scan logged (fallback): [$type] $value');
      }
    } else {
      debugPrint('📱 Scan logged (offline): [$type] $value');
    }
  }
}
