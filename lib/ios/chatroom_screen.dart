import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../chatroom_manager.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;

  ChatRoomScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late DialogFlowtter dialogflow;
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  late ChatRoomManager manager;

  @override
  void initState() {
    super.initState();
    manager = ChatRoomManager();
    var existingRoom = manager.getRoom(widget.roomId);
    if (existingRoom != null) {
      messages = existingRoom.messages;
    }

    // DialogFlowtter 초기화
    DialogFlowtter.fromFile(path: 'assets/cred.json').then((instance) {
      setState(() {
        dialogflow = instance;
      });
    }).catchError((error) {
      print("Failed to load Dialogflow credentials: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('ChakBot'),
        backgroundColor: CupertinoColors.systemIndigo,
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message['userType'] == 'ChakBot' ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: message['userType'] == 'ChakBot'
                            ? CupertinoColors.activeGreen.withOpacity(0.3)
                            : CupertinoColors.activeBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${message['userType'] == 'ChakBot' ? 'ChakBot: ' : 'You: '}${message['text']}',
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CupertinoTextField(
                      controller: messageController,
                      placeholder: '메시지를 입력하세요...',
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    child: Text('전송'),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    String text = messageController.text.trim();
    if (text.isNotEmpty && dialogflow != null) {
      var now = DateTime.now();
      setState(() {
        messages.add({
          'id': now.millisecondsSinceEpoch.toString(),
          'userType': 'You',
          'text': text,
        });
        messageController.clear();
      });

      // 메시지 업데이트 메서드 실행 완료를 기다림
      manager.updateLastMessage(widget.roomId, text, now);

      // Dialogflow 연동
      DetectIntentResponse response = await getResponse(dialogflow, text);

      print(response.toJson());
      print(response.message);
      print(response.text);

      // Bot 응답 시뮬레이션
      var botResponse = response.text;
      await Future.delayed(Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
      setState(() {
        messages.add({
          'id': now.add(Duration(seconds: 1)).millisecondsSinceEpoch.toString(),
          'userType': 'ChakBot',
          'text': botResponse,
        });
      });
      manager.updateLastMessage(widget.roomId, botResponse as String, now.add(Duration(seconds: 1)));
    }
  }

  Future<DetectIntentResponse> getResponse(DialogFlowtter dialogflow, String query) async {
    final QueryInput queryInput = QueryInput(text: TextInput(text: query));
    final DetectIntentResponse response = await dialogflow.detectIntent(queryInput: queryInput);
    return response;
  }

  @override
  void dispose() {
    super.dispose();
    dialogflow.dispose();
  }
}
