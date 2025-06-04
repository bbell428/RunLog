// Bloc
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:runlog/bloc/event/running_map_event.dart';
import 'package:runlog/bloc/state/running_map_state.dart';

class RunningMapBloc extends Bloc<RunningMapEvent, RunningMapState> {
  StreamSubscription<Position>? _positionSubscription;

  RunningMapBloc() : super(RunningMapInitial()) {
    on<GetCurrentLocationRequested>(_onGetCurrentLocationRequested);
    on<RunningLocationChanged>(_onRunningLocationChanged);
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

      // 위치 스트림 시작
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // 5미터 이상 이동해야 이벤트 발생
        ),
      ).listen((Position position) {
        add(RunningLocationChanged(
          LatLng(position.latitude, position.longitude),
        ));
      });
    } catch (e) {
      emit(RunningMapError('위치 스트림 실패: $e'));
    }
  }

  // 실시간 자신 위치 추적
  void _onRunningLocationChanged(
    RunningLocationChanged event,
    Emitter<RunningMapState> emit,
  ) {
    emit(RunningMapLoaded(event.position));
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}