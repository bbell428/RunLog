abstract class RunningResultEvent {}

class SaveRunningResultEvent extends RunningResultEvent {
  final String uid;
  final double distance;
  final Duration duration;

  SaveRunningResultEvent({required this.uid, required this.distance, required this.duration});
}