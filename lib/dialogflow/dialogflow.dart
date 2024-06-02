import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'info.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Info info = Info();


Future<DialogFlowtter> getDialogflow() async {
  final String response = await rootBundle.loadString('assets/credentials.json');
  final Map<String, dynamic> credentials = json.decode(response);

  DialogAuthCredentials dialogAuthCredentials = DialogAuthCredentials.fromJson(credentials);

  final DialogFlowtter dialogflow = DialogFlowtter(
      credentials: dialogAuthCredentials,
      sessionId: info.sessionId,
      projectId: info.projectId
  );


  return dialogflow;
}