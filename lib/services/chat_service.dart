import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';

class ChatService {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';
  final http.Client _client = http.Client();

  ChatService({required this.apiKey});

  Future<Message> sendMessageWithSystemPrompt(
    String text,
    String systemPrompt,
    List<Message> previousMessages,
  ) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('API key is not configured');
      }

      // Prepare messages array with system prompt and conversation history
      final messages = [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        // Add previous messages
        ...previousMessages.map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        }).toList(),
        // Add current message
        {
          'role': 'user',
          'content': text,
        },
      ];

      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',  // Using GPT-4 model
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        
        return Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: botResponse,
          timestamp: DateTime.now(),
          isUser: false,
        );
      } else {
        print('OpenAI API Error: ${response.body}');  // Debug log
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to get response from OpenAI: $errorMessage');
      }
    } catch (e) {
      print('Error in sendMessageWithSystemPrompt: $e');  // Debug log
      String errorMessage = 'Error: Failed to get response from AI. ';
      if (e.toString().contains('API key')) {
        errorMessage += 'Please check your API key configuration.';
      } else if (e.toString().contains('Failed to connect')) {
        errorMessage += 'Please check your internet connection.';
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

      // Prepare messages array with system prompt, conversation history, and image
      final messages = [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        // Add previous messages
        ...previousMessages.map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
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
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',  // Using GPT-4 Vision model for image analysis
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        
        return Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: botResponse,
          timestamp: DateTime.now(),
          isUser: false,
        );
      } else {
        print('OpenAI API Error: ${response.body}');
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to get response from OpenAI: $errorMessage');
      }
    } catch (e) {
      print('Error in sendMessageWithImage: $e');
      String errorMessage = 'Error: Failed to process image. ';
      if (e.toString().contains('API key')) {
        errorMessage += 'Please check your API key configuration.';
      } else if (e.toString().contains('Failed to connect')) {
        errorMessage += 'Please check your internet connection.';
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