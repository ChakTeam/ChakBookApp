//matrial_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chatroom_manager.dart';
import 'chatroom_screen.dart';
import '../chatroom_model.dart';
class ChakBotMaterialApp extends StatelessWidget {
  final String title;

  ChakBotMaterialApp({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatRoomManager()),
      ],
      child: MaterialApp(
        home: ChakBotScreen(title: title),
      ),
    );
  }
}

class ChakBotScreen extends StatefulWidget {
  final String title;

  const ChakBotScreen({Key? key, required this.title}) : super(key: key);

  @override
  _ChakBotScreenState createState() => _ChakBotScreenState();
}

class _ChakBotScreenState extends State<ChakBotScreen> {
  void _startNewChatRoom() {
    final manager = Provider.of<ChatRoomManager>(context, listen: false);
    String newRoomId = DateTime.now().millisecondsSinceEpoch.toString();
    ChatRoom newRoom = ChatRoom(
        id: newRoomId,
        lastMessage: 'Welcome to your new chat!',
        lastMessageTime: DateTime.now(),
        messages: []
    );

    manager.addChatRoom(newRoom);
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatRoomScreen(roomId: newRoomId)
    ));
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ChatRoomManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ChakBot'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.indigo,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('안녕하세요 👋', style: TextStyle(fontSize: 20, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('챗봇이 최적의 책을 추천해드립니다. 대화를 통해 필요하는 스타일의 책을 추천받을 수 있습니다.', style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            backgroundColor: Colors.white
                        ),
                        onPressed: _startNewChatRoom,
                        child: const Text('Start Conversation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          ...manager.chatRooms.map((chat) => buildChatListItem(chat)).toList(),
        ],
      ),
    );
  }

  Widget buildChatListItem(ChatRoom chat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(chat.lastMessage),
        subtitle: Text('ChakBot - ${chat.lastMessageTime}'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ChatRoomScreen(roomId: chat.id)
          ));
        },
      ),
    );
  }
}
