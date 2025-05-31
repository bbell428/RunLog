import 'package:flutter/material.dart';

// static 변수로 인스턴스 생성 없이 사용
// MediaQuery: 기기 화면 너비/높이
class Design {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}