import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'providers/chat_provider.dart';
import 'config/api_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables first
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
    // You might want to handle this error differently in production
    rethrow;
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  final String? openaiApiKey = dotenv.env['OPENAI_API_KEY'];
  
  if (openaiApiKey == null || openaiApiKey.isEmpty) {
    throw Exception('OPENAI_API_KEY not found in .env file');
  }

  // Validate Supabase environment variables
  _validateSupabaseEnvVars();

  ApiConfig.setApiKey(openaiApiKey);
  
  // Load Google Fonts
  await _loadFonts();
  
  // Force RTL test (for debugging only, remove in production)
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(const MyApp());
}

// Function to validate Supabase environment variables
void _validateSupabaseEnvVars() {
  final requiredEnvVars = [
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
  ];
  
  for (final envVar in requiredEnvVars) {
    if (dotenv.env[envVar] == null || dotenv.env[envVar]!.isEmpty) {
      throw Exception('$envVar not found in .env file');
    }
  }
}

Future<void> _loadFonts() async {
  // Preload fonts for Indic scripts
  await GoogleFonts.pendingFonts([
    GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.w400),  // Hindi
    GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.w700),  // Hindi Bold
    GoogleFonts.notoSansTamil(fontWeight: FontWeight.w400),       // Tamil
    GoogleFonts.notoSansTamil(fontWeight: FontWeight.w700),       // Tamil Bold
    GoogleFonts.notoSansTelugu(fontWeight: FontWeight.w400),      // Telugu
    GoogleFonts.notoSansTelugu(fontWeight: FontWeight.w700),      // Telugu Bold
    GoogleFonts.notoSansKannada(fontWeight: FontWeight.w400),     // Kannada
    GoogleFonts.notoSansKannada(fontWeight: FontWeight.w700),     // Kannada Bold
    GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w400),   // Malayalam
    GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w700),   // Malayalam Bold
  ]);
  
  // Force load system fonts 
  await _preloadSystemFonts();
}

Future<void> _preloadSystemFonts() async {
  // Create a dummy paragraph to force load system fonts
  final builder = ui.ParagraphBuilder(ui.ParagraphStyle())
    ..pushStyle(ui.TextStyle(
      fontFamily: 'Noto Sans Devanagari',
      fontSize: 14.0,
    ))
    ..addText('हिन्दी')  // Hindi
    ..pushStyle(ui.TextStyle(
      fontFamily: 'Noto Sans Tamil',
      fontSize: 14.0,
    ))
    ..addText('தமிழ்')  // Tamil
    ..pushStyle(ui.TextStyle(
      fontFamily: 'Noto Sans Telugu',
      fontSize: 14.0,
    ))
    ..addText('తెలుగు')  // Telugu
    ..pushStyle(ui.TextStyle(
      fontFamily: 'Noto Sans Kannada',
      fontSize: 14.0,
    ))
    ..addText('ಕನ್ನಡ')  // Kannada
    ..pushStyle(ui.TextStyle(
      fontFamily: 'Noto Sans Malayalam',
      fontSize: 14.0,
    ))
    ..addText('മലയാളം');  // Malayalam
    
  final paragraph = builder.build();
  paragraph.layout(const ui.ParagraphConstraints(width: 300));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(
        apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
      ),
      child: MaterialApp(
        title: 'Medical Assistant',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Nunito',
          // Add text theme for better font rendering across languages
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.nunitoSans(),
            bodyMedium: GoogleFonts.nunitoSans(),
            labelLarge: GoogleFonts.nunitoSans(),
            titleMedium: GoogleFonts.nunitoSans(),
            titleLarge: GoogleFonts.nunitoSans(),
            headlineMedium: GoogleFonts.nunitoSans(),
          ),
        ),
        supportedLocales: const [
          Locale('en', 'US'),  // English
          Locale('hi', 'IN'),  // Hindi
          Locale('ta', 'IN'),  // Tamil
          Locale('te', 'IN'),  // Telugu
          Locale('kn', 'IN'),  // Kannada
          Locale('ml', 'IN'),  // Malayalam
        ],
        locale: const Locale('en', 'US'),  // Default locale
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 