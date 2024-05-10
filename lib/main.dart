//main.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ios/cupertino_main.dart';
import '../android/material_main.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String titleApp = "My App"; // 상수명은 일반적으로 첫 글자를 소문자로 시작

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // iOS 디자인 대응
      return CupertinoApp(
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.systemBlue,
        ),
        home: ChakBotCupertinoApp(title: titleApp), // iOS용 메인 위젯
      );
    } else {
      // Android 및 기타 플랫폼 디자인 대응
      return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ChakBotMaterialApp(title: titleApp), // Android용 메인 위접
      );
    }
  }
}