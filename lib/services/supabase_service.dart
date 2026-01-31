import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/scan_log.dart';
import '../data/models/digital_card.dart';

/// Supabase service – scan logs, digital cards.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static bool get isAvailable => _client != null;

  static Future<void> initialize() async {
    // Supabase is initialized in main.dart
  }

  /// ตรวจสอบการเชื่อมต่อ Supabase (ใช้ในทดสอบหรือหน้า settings)
  static Future<bool> checkConnection() async {
    if (!isAvailable) return false;
    try {
      await _client!.from('scan_logs').select().limit(1);
      return true;
    } catch (e, st) {
      debugPrint('SupabaseService.checkConnection error: $e\n$st');
      return false;
    }
  }

  /// บันทึกการสแกน (QR หรือ NFC)
  /// RLS: เฉพาะผู้ใช้ที่ล็อกอินแล้วจึงบันทึกลง Supabase ได้; ไม่ล็อกอินจะ log เฉพาะ local
  static Future<void> saveScanLog({
    required String type,
    required String value,
    String? deviceId,
  }) async {
    if (!isAvailable) {
      debugPrint('📱 Scan logged (offline): [$type] $value');
      return;
    }
    final userId = _client!.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('📱 Scan logged (local only, sign in to sync): [$type] $value');
      return;
    }
    try {
      await _client!.from('scan_logs').insert({
        'type': type,
        'value': value,
        'user_id': userId,
        if (deviceId != null) 'device_id': deviceId,
      });
    } catch (e, st) {
      debugPrint('SupabaseService.saveScanLog error: $e\n$st');
      rethrow;
    }
  }

  /// ดึง scan logs (ล่าสุดก่อน)
  static Future<List<ScanLog>> getScanLogs({int limit = 50}) async {
    if (!isAvailable) return [];
    try {
      final userId = _client!.auth.currentUser?.id;
      final data = userId != null
          ? await _client!
              .from('scan_logs')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(limit)
          : await _client!
              .from('scan_logs')
              .select()
              .order('created_at', ascending: false)
              .limit(limit);
      return (data as List)
          .map((e) => ScanLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('SupabaseService.getScanLogs error: $e\n$st');
      return [];
    }
  }

  /// สร้าง digital card
  static Future<DigitalCard?> createDigitalCard({
    required String userId,
    required String name,
    String? title,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? address,
    Map<String, String>? socialLinks,
    String? qrCodeUrl,
    String? nfcTagId,
  }) async {
    if (!isAvailable) return null;
    try {
      final now = DateTime.now().toUtc();
      final data = await _client!.from('digital_cards').insert({
        'user_id': userId,
        'name': name,
        'title': title,
        'company': company,
        'phone': phone,
        'email': email,
        'website': website,
        'address': address,
        'social_links': socialLinks,
        'qr_code_url': qrCodeUrl,
        'nfc_tag_id': nfcTagId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }).select().single();
      return DigitalCard.fromJson(data as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('SupabaseService.createDigitalCard error: $e\n$st');
      rethrow;
    }
  }

  /// ดึง digital cards ของ user
  static Future<List<DigitalCard>> getDigitalCards({required String userId}) async {
    if (!isAvailable) return [];
    try {
      final data = await _client!
          .from('digital_cards')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      return (data as List)
          .map((e) => DigitalCard.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('SupabaseService.getDigitalCards error: $e\n$st');
      return [];
    }
  }

  /// อัปเดต digital card
  static Future<DigitalCard?> updateDigitalCard(DigitalCard card) async {
    if (!isAvailable) return null;
    try {
      final now = DateTime.now().toUtc();
      final data = await _client!
          .from('digital_cards')
          .update({
            'name': card.name,
            'title': card.title,
            'company': card.company,
            'phone': card.phone,
            'email': card.email,
            'website': card.website,
            'address': card.address,
            'social_links': card.socialLinks,
            'qr_code_url': card.qrCodeUrl,
            'nfc_tag_id': card.nfcTagId,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', card.id)
          .select()
          .single();
      return DigitalCard.fromJson(data as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('SupabaseService.updateDigitalCard error: $e\n$st');
      rethrow;
    }
  }

  /// ลบ digital card
  static Future<void> deleteDigitalCard(String id) async {
    if (!isAvailable) return;
    try {
      await _client!.from('digital_cards').delete().eq('id', id);
    } catch (e, st) {
      debugPrint('SupabaseService.deleteDigitalCard error: $e\n$st');
      rethrow;
    }
  }
}
