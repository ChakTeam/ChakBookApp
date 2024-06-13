import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import '../chatroom_manager.dart';
import '../dialogflow/dialogflow.dart';
import '../dialogflow/dialogflow_service.dart';
import '../model/book.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;

  ChatRoomScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late DialogFlowtter dialogflow = getDialogflow();
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  late ChatRoomManager manager;
  List<Book>? bookList;

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
                if (message['type'] == 'book') {
                  return BookMessageWidget(book: message['book']);
                } else {
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
                }
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


      // dialogflow 연동
      DetectIntentResponse response = await getResponse(dialogflow, text);

      // print(response.toJson());
      // print(response.message);
      // print(response.text);
      String intent = response.toJson()['queryResult']['intent']['displayName'];
      print(intent); // intent 반환

      // // 검색 관련 intent일 경우에 검색
      if ( intent == "001-Book Start" ||
          intent == "010-different-book" ) {
      } else{
        bookList = await bookFind(response);
      }
      print(response);



      // Bot 응답 시뮬레이션
      var botResponse = response.text;
      //await Future.delayed(Duration(seconds: 1));  // 네트워크 지연 시뮬레이션
      setState(() {
        messages.add({
          'id': now.add(Duration(seconds: 1)).millisecondsSinceEpoch.toString(),
          'userType': 'ChakBot',
          'text': botResponse,
          'time': now.add(Duration(seconds: 1)),
        });
      });
      manager.updateLastMessage(widget.roomId, botResponse as String, now.add(Duration(seconds: 1)));
    }
    // bookList가 null이 아닌 경우에만 출력
    if (bookList != null) {
      for (Book book in bookList!) {
        setState(() {
          messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'userType': 'ChakBot',
            'type': 'book',
            'book': book,
            'time': DateTime.now(),
          });
        });
      }
    } else {
      print('Book list is null.');
    }
  }

  @override
  void dispose() {
    super.dispose();
    dialogflow.dispose();
  }
}
class BookMessageWidget extends StatelessWidget {
  final Book book;

  const BookMessageWidget({Key? key, required this.book}) : super(key: key);

  bool _isValidUrl(String? url) {
    return url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.2))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isValidUrl(book.thumbnail))
              Image.network(
                book.thumbnail!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 100,
                width: 100,
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade700,
                  size: 50,
                ),
              ),
            SizedBox(height: 8),
            Text(
              book.title ?? 'No title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (book.authors != null)
              Text(
                'Author(s): ${book.authors!.join(', ')}',
                style: TextStyle(fontSize: 14),
              ),
            if (book.contents != null)
              Text(
                'Contents: ${book.contents}',
                style: TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
