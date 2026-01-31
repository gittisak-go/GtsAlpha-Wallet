import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration – URL and Anon Key.
/// Uses environment variables from .env when available.
abstract final class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL (from .env or fallback placeholder).
  static String get url {
    final v = dotenv.env['SUPABASE_URL'];
    return (v != null && v.isNotEmpty) ? v : _fallbackUrl;
  }

  /// Supabase anon/public key (from .env or fallback placeholder).
  static String get anonKey {
    final v = dotenv.env['SUPABASE_ANON_KEY'];
    return (v != null && v.isNotEmpty) ? v : _fallbackAnonKey;
  }

  /// Placeholder when .env is not used – replace with your project values.
  static const String _fallbackUrl = '';
  static const String _fallbackAnonKey = '';
}
