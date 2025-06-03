// 이벤트
abstract class RunningMapEvent {}

class GetCurrentLocationRequested extends RunningMapEvent {} // 현재 위치를 요청하는 이벤트