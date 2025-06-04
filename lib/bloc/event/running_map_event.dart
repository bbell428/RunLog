// 이벤트
import 'package:latlong2/latlong.dart';

abstract class RunningMapEvent {}

class GetCurrentLocationRequested extends RunningMapEvent {} // 현재 위치를 요청하는 이벤트

class RunningLocationChanged extends RunningMapEvent { // 실시간 위치 변화
  final LatLng position;
  RunningLocationChanged(this.position);
}

class StartRunning extends RunningMapEvent {} // 운동 시작
class StopRunning extends RunningMapEvent {}  // 운동 종료
class Tick extends RunningMapEvent {}