import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  final ChatService _chatService;
  final SupabaseService _supabaseService;
  String _userName = 'User';
  int _userAge = 0;
  String _userGender = '';

  ChatProvider({required String apiKey}) 
      : _chatService = ChatService(apiKey: apiKey),
        _supabaseService = SupabaseService(Supabase.instance.client) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _supabaseService.getUserProfile('phone_number');
      if (userProfile != null) {
        _userName = userProfile['name'] ?? 'User';
        _userAge = userProfile['age'] ?? 0;
        _userGender = userProfile['gender'] ?? '';
        
        // Add initial greeting message with user's name
        _messages.add(Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: "Hello ${_userName}! What brings you here today?",
          timestamp: DateTime.now(),
          isUser: false,
        ));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Add generic greeting if profile loading fails
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "Hello! What brings you here today?",
        timestamp: DateTime.now(),
        isUser: false,
      ));
      notifyListeners();
    }
  }

  String get _systemPrompt => """
You are a friendly, conversational medical assistant. Follow these guidelines:

1. Start by asking what brings the user here today. Do not ask about medical history as it's already available.

2. When analyzing the user's current health concern:
   - Consider their age ($_userAge) and gender ($_userGender)
   - Check if there's any connection between their current issue and their medical history
   - If there's a relevant connection, mention it briefly and explain why it's important
   - If there's no relevant connection, focus on the current issue without mentioning past conditions

3. When presenting options to the user, format them in a special way that can be parsed for selection:
   [OPTIONS]
   Please describe your headache:
   [1] Sharp pain
   [2] Dull ache
   [3] Throbbing sensation
   [4] Other (please describe)
   [/OPTIONS]
   
   The user can select an option by touching it or type their own response.

4. Keep responses short and conversational - use 1-3 sentences where possible.
5. Speak naturally like a real doctor or nurse would in conversation.
6. Ask focused follow-up questions about symptoms - one question at a time.
7. Present options when appropriate (like pain types, severity, etc.) using the [OPTIONS] format.
8. Use a warm, empathetic tone while maintaining professionalism.
9. For common ailments, suggest 2-3 specific over-the-counter medicines available in India from our medicine list, including both brand name and generic name. For example: "For your fever, you might consider taking:

    [OPTIONS]
    [1] Dolo 650 (Paracetamol)
    [2] Crocin (Paracetamol)
    [/OPTIONS]"

10. After suggesting medication, recommend consulting a healthcare professional for proper diagnosis and treatment.
11. Clearly state you're an AI assistant, not a replacement for professional medical care.
12. When discussing serious symptoms, recommend seeing a doctor immediately.
13. Prioritize clarity and brevity over comprehensiveness.
14. Address the user by their name ($_userName) when appropriate.
15. Take into account the user's medical history from their profile when providing advice, but only mention it if it's relevant to their current concern.

Remember: Be conversational and human-like. Focus on understanding the user's current medical concerns and providing appropriate guidance based on their age, gender, and medical history.
""";

  List<Message> get messages => _messages;

  // Add method to parse options from message
  List<String>? _parseOptions(String message) {
    final optionsMatch = RegExp(r'\[OPTIONS\](.*?)\[/OPTIONS\]', dotAll: true).firstMatch(message);
    if (optionsMatch == null) return null;
    
    final optionsText = optionsMatch.group(1);
    final options = RegExp(r'\[(\d+)\]\s*(.*?)(?=\n|$)')
        .allMatches(optionsText!)
        .map((match) => match.group(2)!)
        .toList();
    
    return options;
  }

  // Add method to get message without options
  String _getMessageWithoutOptions(String message) {
    return message.replaceAll(RegExp(r'\[OPTIONS\].*?\[/OPTIONS\]', dotAll: true), '').trim();
  }

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
      
      // Parse options from the bot's response
      final options = _parseOptions(botMessage.text);
      final messageWithoutOptions = _getMessageWithoutOptions(botMessage.text);
      
      // Create a new message with parsed options
      final messageWithOptions = Message(
        id: botMessage.id,
        text: messageWithoutOptions,
        timestamp: botMessage.timestamp,
        isUser: false,
        options: options,
      );
      
      _messages.add(messageWithOptions);
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
      text: "Hello ${_userName}! What brings you here today?",
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