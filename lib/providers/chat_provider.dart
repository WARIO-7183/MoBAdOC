import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  final ChatService _chatService;
  static const String _systemPrompt = """
You are a friendly, conversational medical assistant. Follow these guidelines:

1. When presenting options to the user, always format them as a simple numbered list:
   Example:
   Please describe your headache:
   1. Sharp pain
   2. Dull ache
   3. Throbbing sensation
   4. Other (please describe)
   
   Reply with the number of your choice or type your own response.
5. When asking about health issues, provide examples as numbered options.
7. Keep responses short and conversational - use 1-3 sentences where possible.
8. Speak naturally like a real doctor or nurse would in conversation.
9. Ask focused follow-up questions about symptoms - one question at a time.
10. Present options when appropriate (like pain types, severity, etc.) using simple numbers (1. 2. 3. etc).
11. Use a warm, empathetic tone while maintaining professionalism.
12. For common ailments, suggest 2-3 specific over-the-counter medicines available in India from our medicine list, including both brand name and generic name. For example: "For your fever, you might consider taking:

    1. Dolo 650 (Paracetamol)
    2. Crocin (Paracetamol)"

13. After suggesting medication, recommend consulting a healthcare professional for proper diagnosis and treatment.
14. Clearly state you're an AI assistant, not a replacement for professional medical care.
15. When discussing serious symptoms, recommend seeing a doctor immediately.
16. Prioritize clarity and brevity over comprehensiveness.

Remember: Be conversational and human-like. Follow the exact sequence: 1) ask name, 2) ask age and gender, 3) ask about medical conditions with examples.
""";

  ChatProvider({required String apiKey}) 
      : _chatService = ChatService(apiKey: apiKey) {
    // Add initial greeting message
    _messages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hello! I'm your medical assistant. To get started, could you please tell me your name?",
      timestamp: DateTime.now(),
      isUser: false,
    ));
  }

  List<Message> get messages => _messages;

  Future<void> sendMessage(String text) async {
    try {
      // Add user message
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        timestamp: DateTime.now(),
        isUser: true,
      );
      _messages.add(userMessage);
      notifyListeners();

      // Get bot response from OpenAI with system prompt
      final botMessage = await _chatService.sendMessageWithSystemPrompt(
        text,
        _systemPrompt,
        _messages,
      );
      _messages.add(botMessage);
      notifyListeners();
    } catch (e) {
      // Handle error by showing error message
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Error: Failed to send message. Please try again.',
        timestamp: DateTime.now(),
        isUser: false,
      );
      _messages.add(errorMessage);
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    // Add initial greeting message after clearing
    _messages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hello! I'm your medical assistant. To get started, could you please tell me your name?",
      timestamp: DateTime.now(),
      isUser: false,
    ));
    notifyListeners();
  }

  Future<void> sendImageMessage(File imageFile) async {
    try {
      // Add user message with image
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "I've attached a medical report/image",
        timestamp: DateTime.now(),
        isUser: true,
        imageUrl: imageFile.path,
      );
      _messages.add(userMessage);
      notifyListeners();

      // Convert image to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Get bot response from OpenAI with system prompt and image
      final botMessage = await _chatService.sendMessageWithImage(
        "Please analyze this medical report/image and provide insights.",
        base64Image,
        _systemPrompt,
        _messages,
      );
      _messages.add(botMessage);
      notifyListeners();
    } catch (e) {
      print('Error in sendImageMessage: $e'); // Debug log
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Error: Failed to process image. Please try again.',
        timestamp: DateTime.now(),
        isUser: false,
      );
      _messages.add(errorMessage);
      notifyListeners();
    }
  }

  Future<void> sendImageMessageBytes(Uint8List bytes, String fileName) async {
    try {
      // Convert image bytes to base64
      String base64Image = base64Encode(bytes);
      
      // Add user message with image
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "I've attached a medical report/image",
        timestamp: DateTime.now(),
        isUser: true,
        imageUrl: 'data:image/jpeg;base64,$base64Image', // Store the full base64 data
      );
      _messages.add(userMessage);
      notifyListeners();

      // Get bot response from OpenAI with system prompt and image
      final botMessage = await _chatService.sendMessageWithImage(
        "Please analyze this medical report/image and provide insights.",
        base64Image,
        _systemPrompt,
        _messages,
      );
      _messages.add(botMessage);
      notifyListeners();
    } catch (e) {
      print('Error in sendImageMessageBytes: $e'); // Debug log
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Error: Failed to process image. Please try again.',
        timestamp: DateTime.now(),
        isUser: false,
      );
      _messages.add(errorMessage);
      notifyListeners();
    }
  }
} 