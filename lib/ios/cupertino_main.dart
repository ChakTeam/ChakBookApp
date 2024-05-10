//cupertino_main.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'chatroom_screen.dart';
import '../chatroom_manager.dart';
import '../chatroom_model.dart';

class ChakBotCupertinoApp extends StatelessWidget {
  final String title;
  const ChakBotCupertinoApp({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatRoomManager()), // ChatRoomManager를 제공
      ],
      child: CupertinoApp(
        home: ChakBotScreen(title: title), // ChakBotScreen을 MultiProvider 또는 Provider 내에 위치시킴.
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
    Navigator.push(context, CupertinoPageRoute(
        builder: (context) => ChatRoomScreen(roomId: newRoomId)
    ));
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ChatRoomManager>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('ChakBot'),
        backgroundColor: CupertinoColors.systemIndigo,
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemIndigo,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('안녕하세요 👋', style: TextStyle(fontSize: 20, color: CupertinoColors.white)),
                      SizedBox(height: 8),
                      Text('챗봇이 최적의 책을 추천해드립니다. 대화를 통해 필요하는 스타일의 책을 추천받을 수 있습니다.',
                          style: TextStyle(fontSize: 16, color: CupertinoColors.white)),
                      SizedBox(height: 16),
                      Center(
                        child: CupertinoButton(
                          color: CupertinoColors.white,
                          child: Text('Start Conversation', style: TextStyle(color: CupertinoColors.systemPurple)),
                          onPressed: _startNewChatRoom,
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
      ),
    );
  }


// Your buildChatListItem method here
  Widget buildChatListItem(ChatRoom chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(
              builder: (context) => ChatRoomScreen(roomId: chat.id)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(CupertinoIcons.chat_bubble_2, color: CupertinoColors.systemPurple),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chat.lastMessage, style: TextStyle(color: CupertinoColors.black)),
                      SizedBox(height: 4),
                      Text('ChakBot - ${chat.lastMessageTime}', style: TextStyle(color: CupertinoColors.systemGrey)),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.forward, color: CupertinoColors.systemGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
