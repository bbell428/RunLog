import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRunningRepository {
  final _db = FirebaseFirestore.instance;

  // CREATE
  Future<void> saveResult({
    required double distance,
    required Duration duration,
  }) async {
    try {
      await _db.collection('user').doc('result').set({
        'distance': distance,
        'duration': duration.inSeconds,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Firestore 저장 성공: distance=$distance, duration=${duration.inSeconds}s');
    } catch (e) {
      print('Firestore 저장 실패: $e');
      rethrow; // Bloc에서 에러 상태로 전달되도록 유지
    }
  }
}