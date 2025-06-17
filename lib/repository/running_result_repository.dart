import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRunningRepository {
  final _db = FirebaseFirestore.instance;

  // CREATE
  Future<void> saveResult({
    required String uid,
    required double distance,
    required Duration duration,
  }) async {
    final now = DateTime.now();
    final date =
        "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_${_twoDigits(now.hour)}:${_twoDigits(now.minute)}";

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('results')
          .doc(date)
          .set({'distance': distance, 'duration': duration.inSeconds});
      print('Firestore 저장 성공: uid=$uid');
    } catch (e) {
      print('Firestore 저장 실패: $e');
      rethrow;
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
