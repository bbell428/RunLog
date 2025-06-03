// 상태
import 'package:latlong2/latlong.dart';

abstract class RunningMapState {}

class RunningMapInitial extends RunningMapState {}

class RunningMapLoading extends RunningMapState {}

class RunningMapLoaded extends RunningMapState {
  final LatLng currentPosition;
  RunningMapLoaded(this.currentPosition);
}

class RunningMapError extends RunningMapState {
  final String message;
  RunningMapError(this.message);
}