//chatroom_manager.dart
import 'package:flutter/foundation.dart';
import 'chatroom_model.dart';

class ChatRoomManager extends ChangeNotifier {
  static final ChatRoomManager _instance = ChatRoomManager._internal();
  factory ChatRoomManager() {
    return _instance;
  }
  ChatRoomManager._internal();

  final List<ChatRoom> chatRooms = [];

  void addChatRoom(ChatRoom room) {
    if (!chatRooms.any((r) => r.id == room.id)) {
      chatRooms.add(room);
      notifyListeners(); // 상태 변경 알림
    }
  }
  ChatRoom? getRoom(String id) {
    return chatRooms.firstWhere(
            (room) => room.id == id,
        orElse: () => ChatRoom(
            id: 'default',
            lastMessage: 'No message',
            lastMessageTime: DateTime.now(),
            messages: []
        )
    );
  }

  // 마지막 메시지 업데이트
  void updateLastMessage(String id, String message, DateTime messageTime) {
    ChatRoom room = chatRooms.firstWhere(
            (r) => r.id == id,
        orElse: () => ChatRoom(
            id: 'default',
            lastMessage: 'No previous message',
            lastMessageTime: DateTime.now(),
            messages: []
        )
    );

    room.lastMessage = message;
    room.lastMessageTime = messageTime;
    notifyListeners(); // 상태 변경을 알림
  }

}

  final List<ChatRoom> chatRooms = [];

  // 새 채팅방 추가
  void addChatRoom(ChatRoom room) {
    if (!chatRooms.any((r) => r.id == room.id)) {
      chatRooms.add(room);
      print('Added new chat room: ${room.id}');
    } else {
      print('Chat room already exists.');
    }
  }

  // 마지막 메시지 업데이트
  void updateLastMessage(String id, String message, DateTime messageTime) {
    // 일치하는 ID가 없는 경우 기본 ChatRoom 객체를 생성하여 반환
    ChatRoom room = chatRooms.firstWhere(
            (r) => r.id == id,
        orElse: () => ChatRoom(
            id: 'default',
            lastMessage: 'No previous message',
            lastMessageTime: DateTime.now(),
            messages: []
        )
    );

    room.lastMessage = message;
    room.lastMessageTime = messageTime;
  }

