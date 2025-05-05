class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final String? imageUrl;
  final List<String>? options;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.imageUrl,
    this.options,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      isUser: json['isUser'],
      imageUrl: json['imageUrl'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
      'imageUrl': imageUrl,
      'options': options,
    };
  }
} 