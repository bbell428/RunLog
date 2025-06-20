abstract class WorkoutResultState {}

class WorkoutResultInitial extends WorkoutResultState {}

class WorkoutResultLoading extends WorkoutResultState {}

class WorkoutResultLoaded extends WorkoutResultState {
  final Map<DateTime, List<Map<String, dynamic>>> results;
  WorkoutResultLoaded(this.results);
}

class WorkoutResultError extends WorkoutResultState {
  final String message;
  WorkoutResultError(this.message);
}