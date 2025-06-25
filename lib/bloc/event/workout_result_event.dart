abstract class WorkoutResultEvent {}

class LoadWorkoutResults extends WorkoutResultEvent {
  final String uid;
  LoadWorkoutResults(this.uid);
}

class DeleteWorkoutResult extends WorkoutResultEvent {
  final String uid;
  final String docId;

  DeleteWorkoutResult({required this.uid, required this.docId});
}