import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import 'package:flutter/rendering.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: widget.message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.message.isUser 
                  ? const Color(0xFFE7FFDB) // Light green for user messages
                  : Colors.white.withOpacity(0.95), // More opaque white for assistant messages
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.text,
                  style: kMessageStyle,
                ),
                if (!widget.message.isUser) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 20,
                          color: isLiked ? Colors.black : Colors.grey,
                        ),
                        onPressed: _handleLike,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                          size: 20,
                          color: isDisliked ? Colors.black : Colors.grey,
                        ),
                        onPressed: _handleDislike,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        onPressed: _copyToClipboard,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
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
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) {
      var available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              widget.messageController.text = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFFF5F0E8),
      child: Row(
        children: [
          // Mic button
          GestureDetector(
            onTapDown: (_) => _startListening(),
            onTapUp: (_) => _stopListening(),
            onTapCancel: () => _stopListening(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening 
                    ? Colors.red 
                    : const Color(0xFF00A884), // WhatsApp's signature green color
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                ),
                onPressed: null, // Disabled because we're using GestureDetector
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  // Camera icon
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: () {
                      // Implement camera functionality
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.messageController,
                      style: kMessageStyle,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        hintStyle: kHintStyle,
                      ),
                      onSubmitted: (_) => widget.onSend(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF00A884)),
                    onPressed: widget.onSend,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 