import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';
import 'translation_service.dart';

class ChatService {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';
  final http.Client _client = http.Client();
  String _currentLanguage = 'en';

  ChatService({required this.apiKey});

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
  }

  String getCurrentLanguage() {
    return _currentLanguage;
  }

  Future<String> translateText(String text, String targetLanguage) async {
    // Pass through to TranslationService (which now just returns the original text)
    return TranslationService.translateText(text, targetLanguage);
  }

  // Get the language name from language code
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'hi': return "Hindi";
      case 'kn': return "Kannada";
      case 'ta': return "Tamil";
      case 'te': return "Telugu";
      case 'ml': return "Malayalam";
      default: return "English";
    }
  }

  Future<Message> sendMessageWithSystemPrompt(
    String text,
    String systemPrompt,
    List<Message> previousMessages,
  ) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('API key is not configured');
      }

      // We're now sending the original text directly to OpenAI
      // No translation needed as we'll ask the model to respond in the target language
      String userMessage = text;

      // Add language instruction to the system prompt
      String languageInstruction = "";
      if (_currentLanguage != 'en') {
        String languageName = _getLanguageName(_currentLanguage);
        
        // For Indian languages, add special instructions for better rendering
        languageInstruction = '''

Please respond in $languageName. Your response should be entirely in $languageName language.

IMPORTANT: When responding in $languageName, ensure you use proper Unicode characters and not transliteration. Your response must be in native $languageName script.

If providing options, format them as:
[OPTIONS]
[1] Option 1 in $languageName
[2] Option 2 in $languageName
[3] Option 3 in $languageName
[/OPTIONS]
''';
      }

      // Prepare messages array with system prompt and conversation history
      final messages = [
        {
          'role': 'system',
          'content': systemPrompt + languageInstruction,
        },
        ...previousMessages.map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,  // Use text directly
        }).toList(),
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4.1-nano-2025-04-14',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 800,
          'top_p': 0.9,
          'frequency_penalty': 0.5,
          'presence_penalty': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        // Use utf8.decode to ensure proper character encoding
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        String assistantMessage = data['choices'][0]['message']['content'];
        
        // No translation needed as the LLM is already responding in the target language
        return Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: assistantMessage,
          timestamp: DateTime.now(),
          isUser: false,
        );
      } else {
        // Properly decode error messages for better debugging
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to get response from API: ${response.statusCode}\n$errorBody');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      rethrow;
    }
  }

  Future<Message> sendMessageWithImage(
    String text,
    String base64Image,
    String systemPrompt,
    List<Message> previousMessages,
  ) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('API key is not configured');
      }

      // Add language instruction to the system prompt
      String languageInstruction = "";
      if (_currentLanguage != 'en') {
        String languageName = _getLanguageName(_currentLanguage);
        
        // For Indian languages, add special instructions for better rendering
        languageInstruction = '''

Please respond in $languageName. Your response should be entirely in $languageName language.

IMPORTANT: When responding in $languageName, ensure you use proper Unicode characters and not transliteration. Your response must be in native $languageName script.

If providing options, format them as:
[OPTIONS]
[1] Option 1 in $languageName
[2] Option 2 in $languageName
[3] Option 3 in $languageName
[/OPTIONS]
''';
      }
      
      // Enhanced system prompt for image analysis
      String enhancedSystemPrompt = systemPrompt + '''
You are a helpful image analysis assistant that can describe and analyze images in detail.
Please provide detailed descriptions of what you see in images, including objects, scenes, text content, colors, and other visual elements.
For general images, be descriptive and informative.
''' + languageInstruction;

      // Prepare messages array with system prompt, conversation history, and image
      final messages = [
        {
          'role': 'system',
          'content': enhancedSystemPrompt,
        },
        // Add previous messages
        ...previousMessages.map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,  // Use text directly
        }).toList(),
        // Add current message with image
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': text,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ];

      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',  // Using GPT-4o model which includes vision capabilities
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        // Use utf8.decode to ensure proper character encoding
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        final botResponse = data['choices'][0]['message']['content'];
        
        return Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: botResponse,
          timestamp: DateTime.now(),
          isUser: false,
        );
      } else {
        // Properly decode error messages for better debugging
        final errorBody = utf8.decode(response.bodyBytes);
        final errorData = jsonDecode(errorBody);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to get response from OpenAI: $errorMessage');
      }
    } catch (e) {
      print('Error in sendMessageWithImage: $e');
      String errorMessage = 'Error: Failed to process image. ';
      if (e.toString().contains('API key')) {
        errorMessage += 'Please check your API key configuration.';
      } else if (e.toString().contains('Failed to connect')) {
        errorMessage += 'Please check your internet connection.';
      } else if (e.toString().contains('medical') || e.toString().contains('diagnos')) {
        errorMessage = 'Sorry, I cannot analyze medical images or documents. This app can analyze general images like objects, scenes, text, and other common content.';
      } else {
        errorMessage += 'An unexpected error occurred. Please try again.';
      }
      
      return Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: errorMessage,
        timestamp: DateTime.now(),
        isUser: false,
      );
    }
  }

  Future<Message> sendMessage(String text) async {
    return sendMessageWithSystemPrompt(text, "", []);
  }

  void dispose() {
    _client.close();
  }
} 