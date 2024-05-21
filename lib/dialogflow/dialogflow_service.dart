import 'package:dialog_flowtter/dialog_flowtter.dart';

import '../book/book_find.dart';
import '../model/book.dart';

/*
사용
  late DialogFlowtter dialogflow = getDialogflow(); - dialogflow 연동

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
Future<List<Book>?> bookFind(DetectIntentResponse response) async {
  BookService bookService = BookService();

  Map<String, dynamic>? parameters = response.queryResult?.parameters;
  if (parameters != null && parameters["Author"] != null) {
    print("author");
    return bookService.getBookList(parameters["Author"], "Author");
  } else if (parameters != null && parameters["Keyword"] != null) {
    print("Keyword");
    return bookService.getBookList(parameters["Keyword"], "Keyword");
  } else {
    return null;
  }
}
