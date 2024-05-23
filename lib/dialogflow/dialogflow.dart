import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'info.dart';

Info info = Info();


DialogFlowtter getDialogflow() {
  DialogAuthCredentials credentials = DialogAuthCredentials.fromJson(info.key);

  final DialogFlowtter dialogflow = DialogFlowtter(
      credentials: credentials,
      sessionId: info.sessionId,
      projectId: info.projectId
  );

  return dialogflow;
}