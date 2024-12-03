class ChatMessage {
  final int? id;
  final String content;
  final bool isUserMessage;

  ChatMessage({this.id, required this.content, required this.isUserMessage});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isUserMessage': isUserMessage ? 1 : 0,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      content: map['content'],
      isUserMessage: map['isUserMessage'] == 1,
    );
  }
}
