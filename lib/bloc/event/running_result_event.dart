abstract class RunningResultEvent {}

class SaveRunningResultEvent extends RunningResultEvent {
  final double distance;
  final Duration duration;

  SaveRunningResultEvent({required this.distance, required this.duration});
}