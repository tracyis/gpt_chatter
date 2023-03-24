///
/// Created on 2023/3/20.
/// @author Xie Qin
class ChatMessage {
  int role; // 消息的角色，例如发送者或接收者
  String content; // 消息的内容
  bool isSender; // 新增的属性，表示消息是否为发送者发送的

  ChatMessage({
    required this.role,
    required this.content,
    required this.isSender,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      role: map['role'],
      content: map['content'],
      isSender: map['isSender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'isSender': isSender,
    };
  }
}
