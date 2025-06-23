// bloc
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../event/running_map_event.dart';
import '../state/running_map_state.dart';

class RunningMapBloc extends Bloc<RunningMapEvent, RunningMapState> {
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;

  List<LatLng> _path = [];
  double _distance = 0;
  DateTime? _startTime;
  bool _isRunning = false;

  RunningMapBloc() : super(RunningMapInitial()) {
    on<GetCurrentLocationRequested>(_onGetCurrentLocationRequested);
    on<RunningLocationChanged>(_onRunningLocationChanged);
    on<StartRunning>(_onStartRunning);
    on<StopRunning>(_onStopRunning);
    on<Tick>(_onTick);
  }

  Future<void> _onGetCurrentLocationRequested(
    GetCurrentLocationRequested event,
    Emitter<RunningMapState> emit,
  ) async {
    emit(RunningMapLoading());

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(RunningMapError('위치 서비스가 꺼져 있습니다.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(RunningMapError('위치 권한이 거부되었습니다.'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(RunningMapError('위치 권한이 영구적으로 거부되었습니다.'));
        await Geolocator.openAppSettings();
        return;
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 8,
        ),
      ).listen((Position position) {
        add(
          RunningLocationChanged(LatLng(position.latitude, position.longitude)),
        );
      });
    } catch (e) {
      emit(RunningMapError('위치 스트림 실패: $e'));
    }
  }

  void _onRunningLocationChanged(
    RunningLocationChanged event,
    Emitter<RunningMapState> emit,
  ) {
    final current = event.position;
    if (_isRunning) {
      if (_path.isNotEmpty) {
        final prev = _path.last;
        final meter = const Distance().as(LengthUnit.Meter, prev, current);
        if (meter < 8) return; // 노이즈 제거 (8m 이상 이동 시만 저장)
        _distance += meter;
      }
      _path.add(current);
    } else {
      emit(RunningMapLoaded(current));
    }
  }

  void _onStartRunning(
    StartRunning event,
    Emitter<RunningMapState> emit,
  ) async {
    _isRunning = true;
    _startTime = DateTime.now();
    _path = [];
    _distance = 0;

    await FlutterBackgroundService().startService();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(Tick());
    });

    // 위치 업데이트 리스너 등록
    FlutterBackgroundService().on('locationUpdated').listen((data) {
      if (data != null) {
        final lat = data['lat'];
        final lng = data['lng'];
        add(RunningLocationChanged(LatLng(lat, lng)));
      }
    });
  }

  void _onStopRunning(StopRunning event, Emitter<RunningMapState> emit) async {
    _isRunning = false;
    _timer?.cancel();
    FlutterBackgroundService().invoke("stopService");
  }

  void _onTick(Tick event, Emitter<RunningMapState> emit) {
    if (_path.isEmpty || !_isRunning || _startTime == null) return;
    final duration = DateTime.now().difference(_startTime!);
    emit(
      RunningInProgress(
        path: List.from(_path),
        distance: _distance,
        duration: duration,
        currentPosition: _path.last,
      ),
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    return super.close();
  }
}
