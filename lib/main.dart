import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'providers/chat_provider.dart';
import 'config/api_config.dart';
import 'config/firebase_options.dart';

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
  
  // Initialize Firebase with options after environment variables are loaded
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final String? groqApiKey = dotenv.env['GROQ_API_KEY'];
  
  if (groqApiKey == null || groqApiKey.isEmpty) {
    throw Exception('GROQ_API_KEY not found in .env file');
  }

  // Validate Firebase environment variables
  _validateFirebaseEnvVars();

  ApiConfig.setApiKey(groqApiKey);
  
  runApp(const MyApp());
}

// Function to validate Firebase environment variables
void _validateFirebaseEnvVars() {
  final requiredEnvVars = [
    'FIREBASE_API_KEY',
    'FIREBASE_APP_ID',
    'FIREBASE_MESSAGING_SENDER_ID',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_STORAGE_BUCKET',
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