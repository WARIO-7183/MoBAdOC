import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../services/supabase_service.dart';
import '../services/translation_service.dart';
import 'edit_profile_screen.dart'; // Import the new edit profile screen
import 'dart:convert';
import 'ai_call_screen.dart';

// Add TextStyle constants for consistent font usage
const kTitleStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const kMessageStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 16,
  color: Colors.black87,
);

// Create a map of text styles for different languages
Map<String, TextStyle> getLanguageTextStyle(String languageCode) {
  // Default style for Latin scripts
  TextStyle defaultStyle = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    color: Colors.black87,
  );
  
  // Special styles for non-Latin scripts
  switch (languageCode) {
    case 'hi': // Hindi
      return {
        'message': TextStyle(
          fontFamily: 'Noto Sans Devanagari',
          fontSize: 16, 
          color: Colors.black87,
        ),
        'button': TextStyle(
          fontFamily: 'Noto Sans Devanagari',
          fontSize: 14,
          color: Colors.blue[900],
        ),
      };
    case 'ta': // Tamil
      return {
        'message': TextStyle(
          fontFamily: 'Noto Sans Tamil',
          fontSize: 16, 
          color: Colors.black87,
        ),
        'button': TextStyle(
          fontFamily: 'Noto Sans Tamil',
          fontSize: 14,
          color: Colors.blue[900],
        ),
      };
    case 'te': // Telugu
      return {
        'message': TextStyle(
          fontFamily: 'Noto Sans Telugu',
          fontSize: 16, 
          color: Colors.black87,
        ),
        'button': TextStyle(
          fontFamily: 'Noto Sans Telugu',
          fontSize: 14,
          color: Colors.blue[900],
        ),
      };
    case 'kn': // Kannada
      return {
        'message': TextStyle(
          fontFamily: 'Noto Sans Kannada',
          fontSize: 16, 
          color: Colors.black87,
        ),
        'button': TextStyle(
          fontFamily: 'Noto Sans Kannada',
          fontSize: 14,
          color: Colors.blue[900],
        ),
      };
    case 'ml': // Malayalam
      return {
        'message': TextStyle(
          fontFamily: 'Noto Sans Malayalam',
          fontSize: 16, 
          color: Colors.black87,
        ),
        'button': TextStyle(
          fontFamily: 'Noto Sans Malayalam',
          fontSize: 14,
          color: Colors.blue[900],
        ),
      };
    default: // English or any other language
      return {
        'message': defaultStyle,
        'button': TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          color: Colors.blue[900],
        ),
      };
  }
}

const kHintStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 16,
  color: Colors.grey,
);

const kHeaderStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

const kSubtitleStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 16,
  color: Colors.black54,
);

class ChatScreen extends StatefulWidget {
  final String phoneNumber;
  
  const ChatScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final SupabaseService _supabaseService;
  Map<String, dynamic>? _userProfile;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(Supabase.instance.client);
    _loadUserProfile();
    
    // Initialize with the current language from ChatProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLangCode = context.read<ChatProvider>().getCurrentLanguage();
      _selectedLanguage = TranslationService.getLanguageName(currentLangCode);
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _supabaseService.getUserProfile(widget.phoneNumber);
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  void _showProfileDialog() {
    if (_userProfile == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Details', style: kHeaderStyle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProfileDetailRow(
                icon: Icons.person,
                label: 'Name',
                value: _userProfile!['name'] ?? 'Not provided',
              ),
              _ProfileDetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: widget.phoneNumber,
              ),
              _ProfileDetailRow(
                icon: Icons.cake,
                label: 'Age',
                value: _userProfile!['age']?.toString() ?? 'Not provided',
              ),
              _ProfileDetailRow(
                icon: Icons.man,
                label: 'Gender',
                value: _userProfile!['gender'] ?? 'Not provided',
              ),
              _ProfileDetailRow(
                icon: Icons.medical_services,
                label: 'Medical History',
                value: _userProfile!['Medical_history'] ?? 'Not provided',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A884),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    phoneNumber: widget.phoneNumber,
                    userProfile: _userProfile!,
                  ),
                ),
              );
              
              if (result == true) {
                _loadUserProfile(); // Reload the user profile after editing
              }
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TranslationService.getAvailableLanguages().map((language) {
              final languageCode = TranslationService.getLanguageCode(language);
              final isSelected = _selectedLanguage == language;
              final nativeName = TranslationService.getNativeLanguageName(languageCode);
              
              // Get the appropriate font family for the language
              TextStyle nativeTextStyle;
              switch (languageCode) {
                case 'hi':
                  nativeTextStyle = const TextStyle(
                    fontFamily: 'Noto Sans Devanagari',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  );
                  break;
                case 'ta':
                  nativeTextStyle = const TextStyle(
                    fontFamily: 'Noto Sans Tamil',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  );
                  break;
                case 'te':
                  nativeTextStyle = const TextStyle(
                    fontFamily: 'Noto Sans Telugu',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  );
                  break;
                case 'kn':
                  nativeTextStyle = const TextStyle(
                    fontFamily: 'Noto Sans Kannada',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  );
                  break;
                case 'ml':
                  nativeTextStyle = const TextStyle(
                    fontFamily: 'Noto Sans Malayalam',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  );
                  break;
                default:
                  nativeTextStyle = const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  );
              }
              
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nativeName,
                      style: nativeTextStyle,
                    ),
                  ],
                ),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  if (_selectedLanguage == language) {
                    Navigator.pop(context);
                    return;
                  }
                
                  // Show loading indicator while translation happens
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                  
                  try {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    
                    // Update the language in the chat provider
                    final chatProvider = context.read<ChatProvider>();
                    await chatProvider.setLanguage(languageCode);
                    
                    // Close loading dialog
                    if (context.mounted) Navigator.pop(context);
                    
                    // Close language selector
                    if (context.mounted) Navigator.pop(context);
                    
                    // Show a confirmation message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to $nativeName'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    // Close loading dialog
                    if (context.mounted) Navigator.pop(context);
                    
                    // Close language selector
                    if (context.mounted) Navigator.pop(context);
                    
                    // Show error message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to change language: $e'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _createNewChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Chat'),
        content: const Text('Would you like to start a new consultation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().clearMessages();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Started new consultation'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Start New'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A884),
        elevation: 1,
        title: const Row(
          children: [
            Icon(Icons.medical_services_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Medical Assistant',
              style: kTitleStyle,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            tooltip: 'Call AI',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AICallScreen(phoneNumber: widget.phoneNumber),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.black),
            tooltip: 'Select Language',
            onPressed: _showLanguageSelector,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            tooltip: 'Save Conversation',
            onPressed: () async {
              await context.read<ChatProvider>().saveConversationToDatabase(widget.phoneNumber);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation saved to database!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            tooltip: 'View Profile',
            onPressed: _showProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _createNewChat(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/chat_bg.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.3, // Reduced opacity for better readability
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.medical_services, size: 40, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    'AI Medical Assistant',
                    style: kHeaderStyle,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "I'm here to help you with your health concerns. Please note that I'm an AI assistant and not a replacement for professional medical care.",
                      textAlign: TextAlign.center,
                      style: kSubtitleStyle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  // Scroll to bottom when messages change
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      return _buildMessage(message);
                    },
                  );
                },
              ),
            ),
            _MessageInput(
              messageController: _messageController,
              onSend: () {
                if (_messageController.text.trim().isNotEmpty) {
                  context.read<ChatProvider>().sendMessage(_messageController.text);
                  _messageController.clear();
                  _scrollToBottom();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Message message) {
    // Helper to parse options from message text
    List<String> extractOptions(String text) {
      final optionsMatch = RegExp(r'\[OPTIONS\](.*?)\[/OPTIONS\]', dotAll: true).firstMatch(text);
      if (optionsMatch == null) return [];
      
      final optionsText = optionsMatch.group(1);
      return RegExp(r'\[(\d+)\]\s*(.*?)(?=\n|$)')
          .allMatches(optionsText!)
          .map((match) => match.group(2)!)
          .toList();
    }
    
    // Helper to get message without options
    String getMessageWithoutOptions(String text) {
      return text.replaceAll(RegExp(r'\[OPTIONS\].*?\[/OPTIONS\]', dotAll: true), '').trim();
    }
    
    // Use either translated text or original text
    final displayText = message.displayText;
    final messageText = getMessageWithoutOptions(displayText);
    final options = message.options ?? extractOptions(displayText);
    
    // Get the current language code from provider
    final currentLangCode = context.read<ChatProvider>().getCurrentLanguage();
    
    // Get appropriate text styles for the current language
    final textStyles = getLanguageTextStyle(currentLangCode);
    final messageStyle = textStyles['message'] ?? kMessageStyle;
    final buttonStyle = textStyles['button'] ?? TextStyle(
      fontSize: 14,
      color: Colors.blue[900],
    );
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.medical_services, color: Colors.white),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[100] : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageText,
                    style: messageStyle,
                  ),
                  if (options.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: options.map((option) {
                        return ElevatedButton(
                          onPressed: () {
                            context.read<ChatProvider>().sendMessage(option);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            foregroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                          ),
                          child: Text(
                            option,
                            style: buttonStyle,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8.0),
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  void _handleOptionSelected(String option) {
    context.read<ChatProvider>().sendMessage(option);
  }
}

class _MessageBubble extends StatefulWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool isLiked = false;
  bool isDisliked = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleLike() {
    setState(() {
      if (isLiked) {
        isLiked = false;
      } else {
        isLiked = true;
        isDisliked = false;
      }
    });
  }

  void _handleDislike() {
    setState(() {
      if (isDisliked) {
        isDisliked = false;
      } else {
        isDisliked = true;
        isLiked = false;
      }
    });
  }

  Future<Uint8List> _loadImageBytes() async {
    try {
      if (widget.message.imageUrl == null) {
        throw Exception('No image URL provided');
      }

      // Handle base64 encoded images
      if (widget.message.imageUrl!.startsWith('data:image')) {
        final base64Str = widget.message.imageUrl!.split(',')[1];
        return base64Decode(base64Str);
      }

      // Handle file paths (for backward compatibility)
      final file = File(widget.message.imageUrl!);
      if (await file.exists()) {
        return await file.readAsBytes();
      } else {
        throw Exception('File not found: ${widget.message.imageUrl}');
      }
    } catch (e) {
      print('Error loading image: $e');
      rethrow;
    }
  }

  Widget _buildImage() {
    if (widget.message.imageUrl == null) return const SizedBox.shrink();

    return FutureBuilder<Uint8List>(
      future: _loadImageBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            // Show full-screen image preview
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: Stack(
                  children: [
                    InteractiveViewer(
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Hero(
            tag: widget.message.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                snapshot.data!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: widget.message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: widget.message.isUser
                  ? const Color.fromARGB(255, 0, 168, 132)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display message text without options
                Text(
                  _getMessageWithoutOptions(widget.message.text),
                  style: TextStyle(
                    color: widget.message.isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                // Display options as buttons
                if (_hasOptions(widget.message.text))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 8),
                        ..._getOptions(widget.message.text).map((option) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<ChatProvider>().sendMessage(option);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6FFF).withOpacity(0.1),
                              foregroundColor: const Color(0xFF4A6FFF),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (!widget.message.isUser)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.thumb_up,
                      color: isLiked ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    onPressed: _handleLike,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.thumb_down,
                      color: isDisliked ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    onPressed: _handleDislike,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.content_copy,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: _copyToClipboard,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hasOptions(String message) {
    return message.contains('[OPTIONS]') && message.contains('[/OPTIONS]');
  }

  List<String> _getOptions(String message) {
    final optionsMatch = RegExp(r'\[OPTIONS\](.*?)\[/OPTIONS\]', dotAll: true).firstMatch(message);
    if (optionsMatch == null) return [];
    
    final optionsText = optionsMatch.group(1);
    final options = RegExp(r'\[(\d+)\]\s*(.*?)(?=\n|$)')
        .allMatches(optionsText!)
        .map((match) => match.group(2)!)
        .toList();
    
    return options;
  }

  String _getMessageWithoutOptions(String message) {
    return message.replaceAll(RegExp(r'\[OPTIONS\].*?\[/OPTIONS\]', dotAll: true), '').trim();
  }
}

class _MessageInput extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSend;

  const _MessageInput({
    required this.messageController,
    required this.onSend,
  });

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.5);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(text);
    }
  }

  void _stopSpeaking() {
    if (_isSpeaking) {
      _flutterTts.stop();
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickMedia();
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        await context.read<ChatProvider>().sendImageMessageBytes(
          bytes,
          pickedFile.name,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      // Check camera permission
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      // Hide loading indicator
      Navigator.pop(context);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        await context.read<ChatProvider>().sendImageMessageBytes(
          bytes,
          image.name,
        );
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing camera: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        await context.read<ChatProvider>().sendImageMessageBytes(
          bytes,
          image.name,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image from gallery: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFFF5F0E8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickFile,
            color: Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickFromGallery,
            color: Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _pickImage,
            color: Colors.grey[600],
          ),
          IconButton(
            icon: Icon(_isSpeaking ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              if (_isSpeaking) {
                _stopSpeaking();
              } else {
                // Get the latest AI message and speak it
                final messages = context.read<ChatProvider>().messages;
                final aiMessages = messages.where((m) => !m.isUser).toList();
                if (aiMessages.isNotEmpty) {
                  _speak(aiMessages.last.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No AI messages to speak'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            color: Colors.grey[600],
          ),
          Expanded(
            child: TextField(
              controller: widget.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: kHintStyle,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00A884),
            ),
            child: IconButton(
              onPressed: () {
                if (widget.messageController.text.trim().isEmpty) {
                  // Don't send empty messages
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please type a message first'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  widget.onSend();
                }
              },
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 