import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import 'dart:convert';

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
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      return _MessageBubble(message: message);
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
                  ? const Color(0xFF4A6FFF)
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
                Text(
                  widget.message.text,
                  style: TextStyle(
                    color: widget.message.isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                if (widget.message.options != null && widget.message.options!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 8),
                        ...widget.message.options!.map((option) => Padding(
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
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
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