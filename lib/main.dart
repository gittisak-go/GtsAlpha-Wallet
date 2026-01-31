import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'screens/scan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env optional – use fallback / offline mode
  }
  final url = SupabaseConfig.url;
  final anonKey = SupabaseConfig.anonKey;
  if (url.isNotEmpty && anonKey.isNotEmpty) {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
  runApp(const ScanApp());
}

class ScanApp extends StatelessWidget {
  const ScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const ScanScreen(),
    );
  }
}
