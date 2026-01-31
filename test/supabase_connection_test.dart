import 'package:flutter_test/flutter_test.dart';
import 'package:gtsalpha_wallet/services/firebase_service.dart';
import 'package:gtsalpha_wallet/services/supabase_service.dart';

void main() {
  group('Supabase connection and fallback', () {
    test('SupabaseService.isAvailable is false when client not initialized',
        () {
      // In test, Supabase is not initialized so client is null
      expect(SupabaseService.isAvailable, isFalse);
    });

    test('FirebaseService.saveScan completes without throwing when Supabase unavailable',
        () async {
      await expectLater(
        FirebaseService.saveScan(type: 'QR', value: 'test-value'),
        completes,
      );
    });

    test('FirebaseService.saveScan with NFC type completes without throwing',
        () async {
      await expectLater(
        FirebaseService.saveScan(type: 'NFC', value: 'tag-id', deviceId: 'device-1'),
        completes,
      );
    });
  });
}
