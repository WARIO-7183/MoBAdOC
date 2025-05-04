import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'providers/chat_provider.dart';
import 'config/api_config.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(apiKey: ApiConfig.apiKey ?? ''),
      child: MaterialApp(
        title: 'Chat Bot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
} 