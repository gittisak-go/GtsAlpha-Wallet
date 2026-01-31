import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_profile.dart';

/// Auth service – sign up, sign in, sign out, current user.
class AuthService {
  AuthService._();

  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static bool get isAvailable => _client != null;

  static bool get isAuthenticated =>
      isAvailable && _client!.auth.currentUser != null;

  static User? getCurrentUser() => isAvailable ? _client!.auth.currentUser : null;

  /// สมัครสมาชิก (email + password)
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!isAvailable) {
      throw Exception('Supabase is not initialized');
    }
    try {
      final res = await _client!.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );
      if (res.user != null) {
        await _upsertUserProfile(
          id: res.user!.id,
          email: email,
          displayName: displayName,
        );
      }
      return res;
    } catch (e, st) {
      debugPrint('AuthService.signUp error: $e\n$st');
      rethrow;
    }
  }

  /// เข้าสู่ระบบ
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      throw Exception('Supabase is not initialized');
    }
    try {
      return await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e, st) {
      debugPrint('AuthService.signIn error: $e\n$st');
      rethrow;
    }
  }

  /// ออกจากระบบ
  static Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await _client!.auth.signOut();
    } catch (e, st) {
      debugPrint('AuthService.signOut error: $e\n$st');
      rethrow;
    }
  }

  /// ดึงโปรไฟล์ผู้ใช้
  static Future<UserProfile?> getUserProfile(String userId) async {
    if (!isAvailable) return null;
    try {
      final data = await _client!
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserProfile.fromJson(data as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('AuthService.getUserProfile error: $e\n$st');
      return null;
    }
  }

  static Future<void> _upsertUserProfile({
    required String id,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) async {
    if (!isAvailable) return;
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _client!.from('user_profiles').upsert({
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'created_at': now,
        'updated_at': now,
      }, onConflict: 'id');
    } catch (e, st) {
      debugPrint('AuthService._upsertUserProfile error: $e\n$st');
    }
  }

  /// ฟัง auth state changes
  static Stream<AuthState> get authStateChanges =>
      isAvailable ? _client!.auth.onAuthStateChange : const Stream.empty();
}
