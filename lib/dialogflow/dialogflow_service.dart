import 'package:dialog_flowtter/dialog_flowtter.dart';
import '../book/book_find.dart';
import '../model/book.dart';
import 'dialogflow.dart';

/*
  late DialogFlowtter dialogflow = getDialogflow(); // dialogflow 연동

  void sendMessage(String text) async {
    // 빈 문자열 검사 로직

    // 응답 받기
    DetectIntentResponse response = await getResponse(dialogflow, text);

    print(response.toJson());

    // dialogflow 응답 추출
    if (response.message == null) return;
    setState(() {
      addMessage(response.message!);
    });
  }
*/
// 연결 응답 받기
Future<DetectIntentResponse> getResponse(DialogFlowtter dialogflow, String text) async {
  QueryInput queryInput = QueryInput(
    text: TextInput(
      text: text,
      languageCode: "ko",
    ),
  );

  DetectIntentResponse response = await dialogflow.detectIntent(
    queryInput: queryInput,
  );

  return response;
}

// parameter 추출
Future<List<Book>?> bookFind(DetectIntentResponse response, int page) async {
  BookService bookService = BookService();

  Map<String, dynamic>? parameters = response.queryResult?.parameters;
  if (parameters != null && parameters["Author"] != null && parameters["Author"] != "") {
    print("author, parameters : " + parameters["Author"]);
    return bookService.getBookList(parameters["Author"], "person", page);
  } else if (parameters != null && parameters["Keyword"] != null && parameters["Keyword"] != "") {
    print("Keyword, parameters : " + parameters["Keyword"] );
    return bookService.getBookList(parameters["Keyword"], "title", page);
  } else if (parameters != null && parameters["Publisher"] != null && parameters["Publisher"] != ""){
    print("Publisher, parameters : " + parameters["Publisher"] );
    return bookService.getBookList(parameters["Publisher"], "Publisher", page);
  }   else {
    return null;
  }
}
