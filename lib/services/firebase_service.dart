import 'package:flutter/foundation.dart';

/// Layer: Service – Mock บันทึก log การสแกน (ไม่ใช้ Firebase)
/// จะ print ลง console แทน
class FirebaseService {
  static bool get isAvailable => true;

  static Future<void> ensureInitialized() async {
    // No-op: ไม่ใช้ Firebase
  }

  /// บันทึกการสแกน (QR หรือ NFC) - print ลง console
  static Future<void> saveScan({
    required String type,
    required String value,
    String? deviceId,
  }) async {
    debugPrint('📱 Scan logged: [$type] $value');
  }
}
