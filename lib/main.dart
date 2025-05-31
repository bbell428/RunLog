import 'package:flutter/material.dart';
import 'package:runlog/main_tab_View.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '마라톤 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainTabView(),
    );
  }
}