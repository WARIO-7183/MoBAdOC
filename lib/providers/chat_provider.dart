import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/supabase_service.dart';
import '../services/translation_service.dart';
import '../services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  final ChatService _chatService;
  final SupabaseService _supabaseService;
  String _userName = 'User';
  int _userAge = 0;
  String _userGender = '';
  String _currentLanguage = 'en';

  ChatProvider({required String apiKey}) 
      : _chatService = ChatService(apiKey: apiKey),
        _supabaseService = SupabaseService(Supabase.instance.client) {
    _loadUserProfile();
    _addInitialMessage();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _chatService.setLanguage(languageCode);
      
      // Regenerate the initial greeting in the new language
      if (_messages.isNotEmpty) {
        await _regenerateInitialGreeting();
      }
      
      notifyListeners();
    }
  }

  String getCurrentLanguage() {
    return _currentLanguage;
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

  final String _systemPrompt = '''
You are a medical assistant chatbot designed to help users with their health concerns. Your responses should be:

1. Professional and empathetic
2. Focused on providing accurate medical information
3. Clear and easy to understand
4. Culturally sensitive to Indian healthcare practices
5. Supportive of both modern medicine and traditional Indian remedies

When responding to users:
- Always ask relevant follow-up questions
- Provide clear explanations of medical terms
- Suggest appropriate next steps
- Recommend professional medical consultation when necessary
- Never provide definitive diagnoses
- Always err on the side of caution
- Keep responses concise and focused

IMPORTANT: When presenting options to the user, ALWAYS format them using the following template:
[OPTIONS]
[1] First option
[2] Second option
[3] Third option
[4] Fourth option
[/OPTIONS]

The options should be:
- Clear and concise
- Mutually exclusive
- Cover the most common scenarios
- Include an "Other" option when appropriate
- Always numbered sequentially starting from 1
''';

  void _addInitialMessage() {
    _messages.clear();
    final initialMessage = Message(
      id: '1',
      text: 'Hello! How can I help you today? Please share your health concern.\n[OPTIONS]\n[1] I have cold and cough\n[2] I have stomach pain\n[3] I have headache\n[4] I have other issue\n[/OPTIONS]',
      timestamp: DateTime.now(),
      isUser: false,
      options: [
        "I have cold and cough", 
        "I have stomach pain", 
        "I have headache", 
        "I have other issue"
      ],
    );
    
    _messages.add(initialMessage);
    notifyListeners();
    
    // If a non-English language is selected, regenerate the greeting in that language
    if (_currentLanguage != 'en') {
      _regenerateInitialGreeting();
    }
  }

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
    
    return options.isNotEmpty ? options : null;
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
      final botResponse = await _chatService.sendMessageWithSystemPrompt(
        text,
        _systemPrompt,
        _messages,
      );
      
      // Parse options from the bot's response
      final options = _parseOptions(botResponse.text);
      final messageWithoutOptions = _getMessageWithoutOptions(botResponse.text);
      
      // Create a new message with parsed options
      final botMessage = Message(
        id: botResponse.id,
        text: botResponse.text,
        timestamp: botResponse.timestamp,
        isUser: false,
        options: options,
      );
      
      _messages.add(botMessage);
      notifyListeners();

      // Show notification for the bot's response
      await NotificationService.showNotification(
        title: 'Medical Assistant',
        body: messageWithoutOptions,
        payload: botResponse.id,
      );
    } catch (e) {
      print('Error sending message: $e');
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
    
    // Create an initial greeting with options
    final initialMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hello ${_userName}! What brings you here today?\n[OPTIONS]\n[1] I have cold and cough\n[2] I have stomach pain\n[3] I have headache\n[4] I have other issue\n[/OPTIONS]",
      timestamp: DateTime.now(),
      isUser: false,
      options: [
        "I have cold and cough", 
        "I have stomach pain", 
        "I have headache", 
        "I have other issue"
      ],
    );
    
    _messages.add(initialMessage);
    notifyListeners();
    
    // If a non-English language is selected, regenerate the greeting in that language
    if (_currentLanguage != 'en') {
      _regenerateInitialGreeting();
    }
  }
  
  // Generate initial greeting in the selected language
  Future<void> _regenerateInitialGreeting() async {
    try {
      // Clear existing messages
      _messages.clear();
      
      // Create a temporary user message asking for a greeting
      final tempMessage = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        text: "Please introduce yourself as a medical assistant and ask how you can help me today. Include options for common health issues.",
        timestamp: DateTime.now(),
        isUser: true,
      );
      
      // Get a response in the selected language
      final response = await _chatService.sendMessageWithSystemPrompt(
        tempMessage.text,
        _systemPrompt,
        [],
      );
      
      // Parse options from the response
      final options = _parseOptions(response.text);
      
      // Create the greeting message
      final greetingMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response.text,
        timestamp: DateTime.now(),
        isUser: false,
        options: options,
      );
      
      // Add it to the messages list
      _messages.add(greetingMessage);
      notifyListeners();
    } catch (e) {
      print('Error generating initial greeting: $e');
      // Fallback to default greeting if an error occurs
      _addDefaultInitialMessage();
    }
  }
  
  // Fallback method to add a default initial message
  void _addDefaultInitialMessage() {
    _messages.clear();
    final initialMessage = Message(
      id: '1',
      text: 'Hello! How can I help you today? Please share your health concern.\n[OPTIONS]\n[1] I have cold and cough\n[2] I have stomach pain\n[3] I have headache\n[4] I have other issue\n[/OPTIONS]',
      timestamp: DateTime.now(),
      isUser: false,
      options: [
        "I have cold and cough", 
        "I have stomach pain", 
        "I have headache", 
        "I have other issue"
      ],
    );
    
    _messages.add(initialMessage);
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

  // Serialize the conversation as JSON
  String get conversationJson {
    final messagesJson = _messages.map((msg) => msg.toJson()).toList();
    return jsonEncode(messagesJson);
  }

  // Save the conversation to the database
  Future<void> saveConversationToDatabase(String phoneNumber) async {
    final chatRecord = conversationJson;
    await _supabaseService.updateChatRecord(phoneNumber: phoneNumber, chatRecord: chatRecord);
  }

  Future<String?> generateAndSaveReport(String phoneNumber) async {
    try {
      // 1. Fetch all user data
      final userData = await _supabaseService.getFullUserRecord(phoneNumber);
      if (userData == null) throw Exception('User data not found');
      final chatRecord = userData['Chat_record'] ?? '';

      // 2. Prepare prompt for OpenAI
      final prompt = '''Generate a consolidated medical report for the following user. Include all relevant details in a clear, professional, and human-readable format. Use headings and sections where appropriate.

User Profile:
${userData.toString()}

Chat Conversation:
$chatRecord

The report should be suitable for sharing with a doctor or for personal records.''';

      // 3. Get report from OpenAI
      final reportMessage = await _chatService.sendMessageWithSystemPrompt(
        prompt,
        '',
        [],
      );
      final reportText = reportMessage.text;

      // 4. Generate PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Text(reportText, style: pw.TextStyle(fontSize: 14)),
          ),
        ),
      );

      // 5. Save PDF locally
      final outputDir = await getApplicationDocumentsDirectory();
      final filePath = '${outputDir.path}/Medical_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      return filePath;
    } catch (e) {
      print('Error generating report: $e');
      return null;
    }
  }
} 