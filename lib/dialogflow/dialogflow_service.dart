import 'package:dialog_flowtter/dialog_flowtter.dart';
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

