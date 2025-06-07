import 'package:cloud_firestore/cloud_firestore.dart';

class RunningResultRepository {
  final _collection = FirebaseFirestore.instance.collection('running_results');

  Future<void> saveResult({
    required double distance,
    required Duration duration,
  }) async {
    await _collection.add({
      'distance': distance,
      'duration': duration.inSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}