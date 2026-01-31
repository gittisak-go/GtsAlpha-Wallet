import 'package:nfc_manager/nfc_manager.dart';

/// Layer: Service – เปิด NFC session อ่าน UID / NDEF
class NfcService {
  /// เริ่ม session รอ Tap card/ring แล้วอ่าน UID
  static Future<void> startSession({
    required void Function(String uid) onRead,
    void Function(String message)? onError,
  }) async {
    try {
      final isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        onError?.call('NFC ไม่พร้อมบนอุปกรณ์นี้');
        return;
      }
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndef = Ndef.from(tag);
            String value;
            if (ndef != null && ndef.cachedMessage != null) {
              final record = ndef.cachedMessage!.records.isNotEmpty
                  ? ndef.cachedMessage!.records.first
                  : null;
              value = record != null
                  ? String.fromCharCodes(record.payload)
                  : tag.handle.toString();
            } else {
              value = tag.handle.toString();
            }
            onRead(value);
            await NfcManager.instance.stopSession();
          } catch (e) {
            onError?.call(e.toString());
          }
        },
      );
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  static Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }
}
