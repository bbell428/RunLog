abstract class RunningResultState {}

class RunningResultInitial extends RunningResultState {}

class RunningResultSaving extends RunningResultState {}

class RunningResultSaved extends RunningResultState {}

class RunningResultError extends RunningResultState {
  final String message;
  RunningResultError(this.message);
}