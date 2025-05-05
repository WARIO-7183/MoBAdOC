import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/supabase_service.dart';
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

  String get _systemPrompt {
    switch (_currentLanguage) {
      case 'hi':
        return '''आप एक चिकित्सा सहायक हैं। आपका काम रोगियों को उनकी स्वास्थ्य संबंधी चिंताओं के बारे में सलाह देना है। कृपया ध्यान दें कि आप एक AI सहायक हैं और पेशेवर चिकित्सा देखभाल का विकल्प नहीं हैं।

आपको निम्नलिखित दिशा-निर्देशों का पालन करना चाहिए:
1. हमेशा सहानुभूतिपूर्ण और समझदार बनें
2. स्पष्ट और सरल भाषा का प्रयोग करें
3. यदि आप किसी प्रश्न का उत्तर नहीं जानते हैं, तो ईमानदारी से कहें
4. गंभीर लक्षणों के मामले में तुरंत चिकित्सा सहायता लेने की सलाह दें
5. जब भी आप विकल्प प्रस्तुत करें, उन्हें हमेशा इस विशेष प्रारूप में दें:
[OPTIONS]\n[1] विकल्प 1\n[2] विकल्प 2\n[/OPTIONS]\nकभी भी [Option 1], [Option 2] या अन्य स्वरूपों का उपयोग न करें। केवल [OPTIONS] ब्लॉक का उपयोग करें।''';
      case 'kn':
        return '''ನೀವು ವೈದ್ಯಕೀಯ ಸಹಾಯಕರಾಗಿದ್ದೀರಿ. ರೋಗಿಗಳಿಗೆ ಅವರು ಆರೋಗ್ಯ ಸಮಸ್ಯಲು ಬಗ್ಗೆ ಸಲಹೆ ನೀಡುವುದು ನಿಮ್ಮ ಕೆಲಸ. ನೀವು AI ಸಹಾಯಕರಾಗಿದ್ದೀರಿ ಮತ್ತು ವೃತ್ತಿಪರ ವೈದ್ಯಕೀಯ ಚಿಕಿತ್ಸೆಯ ಬದಲಿಯಲ್ಲ ಎಂಬುದನ್ನು ದಯವಿಟ್ಟು ಗಮನಿಸಿ.

ನೀವು ಈ ಕೆಳಗಿನ ಮಾರ್ಗದರ್ಶನಗಳನ್ನು ಅನುಸರಿಸಬೇಕು:
1. ಯಾವಾಗಲೂ ಸಹಾನುಭೂತಿಯುತ ಮತ್ತು ತಿಳಿವಳಿಕೆಯುಳ್ಳವರಾಗಿರಿ
2. ಸ್ಪಷ್ಟ ಮತ್ತು ಸರಳ ಭಾಷೆಯನ್ನು ಬಳಸಿ
3. ನೀವು ಯಾವುದೇ ಪ್ರಶ್ನೆಗೆ ಉತ್ತರವನ್ನು ತಿಳಿದಿಲ್ಲದಿದ್ದರೆ, ಪ್ರಾಮಾಣಿಕವಾಗಿ ಹೇಳಿ
4. ಗಂಭೀರ ಲಕ್ಷಣಗಳ ಸಂದರ್ಭದಲ್ಲಿ ತಕ್ಷಣ ವೈದ್ಯಕೀಯ ಸಹಾಯ ಪಡೆಯಲು ಸಲಹೆ ನೀಡಿ
5. ಯಾವಾಗಲೂ ಆಯ್ಕೆಗಳನ್ನು ಈ ವಿಶೇಷ ರೂಪದಲ್ಲಿ ಮಾತ್ರ ನೀಡಿರಿ:
[OPTIONS]\n[1] ಆಯ್ಕೆ 1\n[2] ಆಯ್ಕೆ 2\n[/OPTIONS]\n[Option 1], [Option 2] ಅಥವಾ ಬೇರೆ ರೂಪಗಳನ್ನು ಬಳಸಬೇಡಿ. ಕೇವಲ [OPTIONS] ಬ್ಲಾಕ್ ಬಳಸಿ.''';
      case 'te':
        return '''మీరు ఒక వైద్య సహాయకుడు. రోగులకు వారి ఆరోగ్య సమస్యల గురించి సలహాలు ఇవ్వడం మీ పని. మీరు AI సహాయకుడు మరియు వృత్తిపర వైద్య సంరక్షణకు ప్రత్యామ్నాయం కాదని దయచేసి గమనించండి.

మీరు ఈ క్రింది మార్గదర్శకాలను అనుసరించాలి:
1. ఎల్లప్పుడూ సానుభూతి మరియు అవగాహనతో ఉండండి
2. స్పష్టమైన మరియు సరళమైన భాషను ఉపయోగించండి
3. మీకు ఏదైనా ప్రశ్నకు సమాధానం తెలియకపోతే, నిజాయితీగా చెప్పండి
4. తీవ్రమైన లక్షణాల సందర్భంలో వెంటనే వైద్య సహాయం పొందమని సలహా ఇవ్వండి
5. ఎప్పుడైనా ఎంపికలను ఈ ప్రత్యేక ఫార్మాట్‌లో మాత్రమే ఇవ్వండి:
[OPTIONS]\n[1] ఎంపిక 1\n[2] ఎంపిక 2\n[/OPTIONS]\n[Option 1], [Option 2] లేదా ఇతర ఫార్మాట్‌లను ఉపయోగించవద్దు. కేవలం [OPTIONS] బ్లాక್‌ను ఉపయోగించండి.''';
      case 'ta':
        return '''நீங்கள் ஒரு மருத்துவ உதவியாளர். நோயாளிகளுக்கு அவர்களின் உடல்நலம் குறித்த கவலைகள் குறித்து ஆலோசனை வழங்குவது உங்கள் வேலை. நீங்கள் ஒரு AI உதவியாளர் மற்றும் தொழில்முறை மருத்துவ பராமரிப்புக்கு மாற்றாக இல்லை என்பதை நினைவில் கொள்ளவும்.

நீங்கள் பின்வரும் வழிகாட்டுதல்களைப் பின்பற்ற வேண்டும்:
1. எப்போதும் அனுதாபமும் புரிதலும் கொண்டவராக இருங்கள்
2. தெளிவான மற்றும் எளிய மொழியைப் பயன்படுத்தவும்
3. எந்த கேள்விக்கும் பதில் தெரியாவிட்டால், நேர்மையாகச் சொல்லுங்கள்
4. தீவிர அறிகுறிகள் ஏற்பட்டால் உடனடியாக மருத்துவ உதவி பெறுமாறு அறிவுறுத்தவும்
5. எப்போதும் விருப்பங்களை இந்த சிறப்பு வடிவத்தில் மட்டும் வழங்கவும்:
[OPTIONS]\n[1] விருப்பம் 1\n[2] விருப்பம் 2\n[/OPTIONS]\n[Option 1], [Option 2] அல்லது பிற வடிவங்களை பயன்படுத்த வேண்டாம். [OPTIONS] பிளாக்கை மட்டும் பயன்படுத்தவும்.''';
      case 'ml':
        return '''നിങ്ങൾ ഒരു മെഡിക്കൽ അസിസ്റ്റന്റാണ്. രോഗികൾക്ക് അവരുടെ ആരോഗ്യ ആശങ്കകളെക്കുറിച്ച് ഉപദേശം നൽകുക എന്നതാണ് നിങ്ങളുടെ ജോലി. നിങ്ങൾ ഒരു AI അസിസ്റ്റന്റ് ആണെന്നും പ്രൊഫഷണൽ മെഡിക്കൽ കെയർ ഒരു പകരമല്ലെന്നും ദയവായി ശ്രദ്ധിക്കുക.

നിങ്ങൾ ഇനിപ്പറയുന്ന മാർഗ്ഗനിർദ്ദേശങ്ങൾ പാലിക്കണം:
1. എല്ലായ്പ്പോഴും സഹാനുഭൂതിയും മനസ്സിലാക്കലും ഉള്ളവരായിരിക്കുക
2. വ്യക്തവും ലളിതവുമായ ഭാഷ ഉപയోഗിക്കുക
3. ഏതെങ്കിലും ചോദ്യത്തിന് ഉത്തരം അറിയാത്തപക്ഷം, സത്യസന്ധമായി പറയുക
4. ഗുരുതരമായ ലക്ഷണങ്ങൾ ഉണ്ടെങ്കിൽ ഉടനടി മെഡിക്കൽ സഹായം തേടാൻ ഉപദേശിക്കുക
5. ഓപ്ഷനുകൾ ഇനിപ്പറയുന്ന ഫോർമാറ്റിൽ അവതരിപ്പിക്കുക:
   [ഓപ്ഷൻ 1]
   [ഓപ്ഷൻ 2]
   [ഓപ്ഷൻ 3]''';
      default:
        return '''You are a medical assistant. Your job is to advise patients about their health concerns. Please note that you are an AI assistant and not a replacement for professional medical care.

You should follow these guidelines:
1. Always be empathetic and understanding
2. Use clear and simple language
3. If you don't know the answer to any question, say so honestly
4. Advise seeking immediate medical help in case of serious symptoms
5. Whenever you present options, ALWAYS use this special format:
[OPTIONS]\n[1] Option 1\n[2] Option 2\n[/OPTIONS]\nNever use [Option 1], [Option 2], or any other format. Only use the [OPTIONS] block.''';
    }
  }

  void _addInitialMessage() {
    _messages.clear();
    switch (_currentLanguage) {
      case 'hi':
        _messages.add(Message(
          id: '1',
          text: 'नमस्ते! आज आप कैसे हैं?',
          timestamp: DateTime.now(),
          isUser: false,
        ));
        break;
      case 'kn':
        _messages.add(Message(
          id: '1',
          text: 'ನಮಸ್ಕಾರ! ಇಂದು ನೀವು ಹೇಗಿದ್ದೀರಿ?',
          timestamp: DateTime.now(),
          isUser: false,
        ));
        break;
      case 'te':
        _messages.add(Message(
          id: '1',
          text: 'నమస్కారం! ఈరోజు మీరు ఎలా ఉన్నారు?',
          timestamp: DateTime.now(),
          isUser: false,
        ));
        break;
      case 'ta':
        _messages.add(Message(
          id: '1',
          text: 'வணக்கம்! இன்று நீங்கள் எப்படி இருக்கிறீர்கள்?',
          timestamp: DateTime.now(),
          isUser: false,
        ));
        break;
      case 'ml':
        _messages.add(Message(
          id: '1',
          text: 'നമസ്കാരം! ഇന്ന് നിങ്ങൾക്ക് എങ്ങനെയുണ്ട്?',
          timestamp: DateTime.now(),
          isUser: false,
        ));
        break;
      default:
        _messages.add(Message(
          id: '1',
          text: 'Hello! How are you today?',
          timestamp: DateTime.now(),
          isUser: false,
        ));
    }
    notifyListeners();
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

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    _addInitialMessage();
    notifyListeners();
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