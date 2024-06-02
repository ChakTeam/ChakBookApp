import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../chatroom_manager.dart';
import '../dialogflow/dialogflow.dart';
import '../dialogflow/dialogflow_service.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('ChakBot'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['userType'] == 'ChakBot' ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                        color: message['userType'] == 'ChakBot' ? Colors.green.shade100 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withOpacity(0.2))
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
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
          'time': now,
        });
        messageController.clear();
      });

      // 메시지 업데이트 메서드 실행 완료를 기다림
      manager.updateLastMessage(widget.roomId, text, now);

      // Dialogflow 연동
      try {
        DetectIntentResponse response = await getResponse(dialogflow!, text);
        print('Response: ${response.toJson()}');

        if (response.message != null && response.message!.text != null && response.message!.text!.text != null && response.message!.text!.text!.isNotEmpty) {
          var botResponse = response.message!.text!.text![0];
          await Future.delayed(Duration(seconds: 1));  // 네트워크 지연 시뮬레이션
          setState(() {
            messages.add({
              'id': now.add(Duration(seconds: 1)).millisecondsSinceEpoch.toString(),
              'userType': 'ChakBot',
              'text': botResponse,
              'time': now.add(Duration(seconds: 1)),
            });
          });
          manager.updateLastMessage(widget.roomId, botResponse, now.add(Duration(seconds: 1)));
        } else {
          print('Error: No response text from Dialogflow.');
        }
      } catch (error) {
        print('Error occurred during Dialogflow request: $error');
      }
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
