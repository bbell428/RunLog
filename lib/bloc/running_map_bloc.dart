// Bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:runlog/bloc/event/running_map_event.dart';
import 'package:runlog/bloc/state/running_map_state.dart';

class RunningMapBloc extends Bloc<RunningMapEvent, RunningMapState> {
  RunningMapBloc() : super(RunningMapInitial()) {
    on<GetCurrentLocationRequested>(_onGetCurrentLocationRequested);
  }

  Future<void> _onGetCurrentLocationRequested(
    GetCurrentLocationRequested event, // 요구사항
    Emitter<RunningMapState> emit, // 알림
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

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      emit(RunningMapLoaded(LatLng(position.latitude, position.longitude)));
    } catch (e) {
      emit(RunningMapError('위치 가져오기 실패: $e'));
    }
  }
}