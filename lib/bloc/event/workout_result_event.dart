abstract class WorkoutResultEvent {}

class LoadWorkoutResults extends WorkoutResultEvent {
  final String uid;
  LoadWorkoutResults(this.uid);
}
