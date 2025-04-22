import 'message.dart';
import 'user.dart';

class Chat {
  final String id;
  final List<Message> messages;
  final User user;
  final DateTime lastMessageTime;

  Chat({
    required this.id,
    required this.messages,
    required this.user,
    required this.lastMessageTime,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      messages: (json['messages'] as List)
          .map((message) => Message.fromJson(message))
          .toList(),
      user: User.fromJson(json['user']),
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messages': messages.map((message) => message.toJson()).toList(),
      'user': user.toJson(),
      'lastMessageTime': lastMessageTime.toIso8601String(),
    };
  }
} 