import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  
  Future<String> generateResponse(String prompt) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null) {
      throw Exception('GROQ_API_KEY not found in environment variables');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'mixtral-8x7b-32768',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate response: ${response.body}');
    }
  }
} 