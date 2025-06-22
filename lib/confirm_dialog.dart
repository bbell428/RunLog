import 'package:flutter/material.dart';

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
