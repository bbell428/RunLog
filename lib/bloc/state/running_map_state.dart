// 상태
import 'package:latlong2/latlong.dart';

abstract class RunningMapState {}

class RunningMapInitial extends RunningMapState {} // 초기 상태 (앱 시작 시)

class RunningMapLoading extends RunningMapState {} // 위치를 가져오는 중 (로딩 상태)

class RunningMapLoaded extends RunningMapState { // 위치를 성공적으로 가져온 상태
  final LatLng currentPosition;
  RunningMapLoaded(this.currentPosition);
}

// 오류 상태 (위치 꺼짐, 권한 거부 등)
class RunningMapError extends RunningMapState {
  final String message;
  RunningMapError(this.message);
}