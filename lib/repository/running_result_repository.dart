import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRunningRepository {
  final _db = FirebaseFirestore.instance;

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatPace(double secondsPerKm) {
    if (secondsPerKm <= 0) return '-';
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm % 60).round();
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }

  // CREATE
  Future<void> saveResult({
    required String uid,
    required double distance,
    required Duration duration,
  }) async {
    final now = DateTime.now();
    final date =
        "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_${_twoDigits(now.hour)}:${_twoDigits(now.minute)}";
    final recordTime =
        "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";

    final distanceKm = distance / 1000;
    final validDurationSec = duration.inSeconds == 0 ? 1 : duration.inSeconds;
    final avgPace = distanceKm == 0 ? 0.0 : validDurationSec / distanceKm;
    final formattedPace = distanceKm < 0.1 ? '-' : _formatPace(avgPace);

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('results')
          .doc(date)
          .set({
            'recordTime': recordTime,
            'distance': distance,
            'duration': duration.inSeconds,
            'formattedPace': formattedPace,
          });
      print('Firestore 저장 성공: uid=$uid');
    } catch (e) {
      print('Firestore 저장 실패: $e');
      rethrow;
    }
  }

  // READ
  Future<Map<DateTime, List<Map<String, dynamic>>>> fetchRunningResults(
    String uid,
  ) async {
    final snapshot =
        await _db.collection('users').doc(uid).collection('results').get();
    final Map<DateTime, List<Map<String, dynamic>>> resultsByDate = {};

    for (var doc in snapshot.docs) {
      final id = doc.id;
      final dateStr = id.split('_').first;
      final date = DateTime.parse(dateStr);

      resultsByDate.putIfAbsent(date, () => []).add({
        'recordTime': doc['recordTime'],
        'distance': doc['distance'],
        'duration': doc['duration'],
        'formattedPace': doc['formattedPace'] ?? '-',
      });
    }

    return resultsByDate;
  }
}
