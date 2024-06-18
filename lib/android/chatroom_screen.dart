import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import '../chatroom_manager.dart';
import '../dialogflow/dialogflow.dart';
import '../dialogflow/dialogflow_service.dart';
import '../model/book.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int page = 1;
  DetectIntentResponse? response;
  ScrollController _scrollController = ScrollController();
  List<Book> selectedBooks = []; // 선택된 책 리스트

  @override
  void initState() {
    super.initState();
    manager = ChatRoomManager();
    var existingRoom = manager.getRoom(widget.roomId);
    if (existingRoom != null) {
      messages = existingRoom.messages;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChakBot'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            color: Colors.white,
            onPressed: saveSelectedBooks,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                if (message['type'] == 'book') {
                  return BookMessageWidget(
                    book: message['book'],
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          selectedBooks.add(message['book']);
                        } else {
                          selectedBooks.remove(message['book']);
                        }
                      });
                    },
                    isSelected: selectedBooks.contains(message['book']),
                  );
                } else {
                  return Align(
                    alignment: message['userType'] == 'ChakBot'
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                          color: message['userType'] == 'ChakBot'
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.2))),
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

  void saveSelectedBooks() {
    var now = DateTime.now();
    print(selectedBooks.length);
    if (selectedBooks.length == 0) {
      setState(() {
        messages.add({
          'id': now.add(Duration(seconds: 1)).millisecondsSinceEpoch.toString(),
          'userType': 'ChakBot',
          'text': "저장된 책이 없습니다.",
          'time': now.add(Duration(seconds: 1)),
        });
      });
    } else {
      setState(() {
        messages.add({
          'id': now.add(Duration(seconds: 1)).millisecondsSinceEpoch.toString(),
          'userType': 'ChakBot',
          'text': "저장된 책입니다.",
          'time': now.add(Duration(seconds: 1)),
        });
      });
      for (Book book in selectedBooks) {
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
    }
    // 스크롤을 아래로 이동
    _scrollToBottom();

    print('Selected books: $selectedBooks');
  }

  void sendMessage() async {
    String text = messageController.text.trim();
    if (text.isNotEmpty) {
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

      // 스크롤을 아래로 이동
      _scrollToBottom();

      // dialogflow 연동
      response = await getResponse(dialogflow, text);

      String intent =
          response!.toJson()['queryResult']['intent']['displayName'];
      print(intent); // intent 반환

      // 검색 관련 intent일 경우에 검색
      if (intent == "001-Book Start") {
      } // 다른 책 요청일 경우 page 변경
      else if (intent == "010-different-book") {
        page++;
        bookList = await bookFind(response!, page);
      } else if (intent == "020-Saved-Book") {
        saveSelectedBooks;
        bookList = selectedBooks;
      } else {
        page = 1;
        bookList = await bookFind(response!, page);
      }
      print(response);

      // Bot 응답 시뮬레이션
      var botResponse = response!.text;
      setState(() {
        messages.add({
          'id': now.add(Duration(seconds: 1)).millisecondsSinceEpoch.toString(),
          'userType': 'ChakBot',
          'text': botResponse,
          'time': now.add(Duration(seconds: 1)),
        });
      });

      // 스크롤을 아래로 이동
      _scrollToBottom();

      manager.updateLastMessage(
          widget.roomId, botResponse as String, now.add(Duration(seconds: 1)));
    }

    // bookList가 null이 아닌 경우에만 출력
    if (bookList?.length != 0) {
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
        // 스크롤을 아래로 이동
        _scrollToBottom();
      }
    } else {
      print('Book list is null.');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    dialogflow.dispose();
  }
}

class BookMessageWidget extends StatelessWidget {
  final Book book;
  final ValueChanged<bool> onSelected;
  final bool isSelected;

  const BookMessageWidget(
      {Key? key,
      required this.book,
      required this.onSelected,
      required this.isSelected})
      : super(key: key);

  bool _isValidUrl(String? url) {
    return url != null &&
        url.isNotEmpty &&
        Uri.tryParse(url)?.hasAbsolutePath == true;
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch $url';
    }
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
            border: Border.all(color: Colors.black.withOpacity(0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _isValidUrl(book.thumbnail)
                      ? Image.network(
                          book.thumbnail!,
                          height: 150,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 150,
                          width: 100,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade700,
                            size: 50,
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title ?? 'No title',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (book.authors != null)
                          Text(
                            '작가 : ${book.authors!.join(', ')}',
                            style: TextStyle(fontSize: 14),
                          ),
                        if (book.contents != null)
                          Text(
                            '내용 : ${book.contents}',
                            style: TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () => onSelected(!isSelected),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected ? Colors.blue : Colors.grey,
                      size: 30.0, // 여기서 아이콘 크기를 지정합니다.
                    ),
                  ),
                ),
              ],
            ),
            if (_isValidUrl(book.url))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: () => _launchURL(book.url!),
                  child: Text('More Info'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
