// 채팅방 데이터 모델
class ChatRoom {
  String id;
  String lastMessage;
  DateTime lastMessageTime;
  List<Map<String, dynamic>> messages;

  ChatRoom({
    required this.id,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.messages,
  });
}
