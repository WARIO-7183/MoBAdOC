import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/chat_screen.dart';
import 'providers/chat_provider.dart';
import 'config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
    // You might want to handle this error differently in production
    rethrow;
  }
  
  final String? groqApiKey = dotenv.env['GROQ_API_KEY'];
  
  if (groqApiKey == null || groqApiKey.isEmpty) {
    throw Exception('GROQ_API_KEY not found in .env file');
  }

  ApiConfig.setApiKey(groqApiKey);
  
  runApp(const MyApp());
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
        home: const ChatScreen(),
      ),
    );
  }
} 