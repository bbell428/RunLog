import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 비동기 알럿창
Future<bool> showConfirmDialog({
  required BuildContext context,
  String title = '제목',
  String content = '내용',
  String cancelText = '취소',
  String confirmText = '확인',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        ),
  );

  return result == true;
}

// 뒤로가기 알럿창
void showExitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('나가기'),
      content: const Text('정말 러닝을 종료하고 나가시겠습니까?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => context.pop(), // 알럿 닫기
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            context.pop(); // 알럿 닫기
            if (context.canPop()) {
              context.pop(); // 이전 화면으로
            } else {
              context.go('/tabView'); // 홈 이동
            }
          },
          child: const Text('확인'),
        ),
      ],
    ),
  );
}