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
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
  );

  return result == true;
}
