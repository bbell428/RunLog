import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runlog/bloc/event/running_result_event.dart';
import 'package:runlog/bloc/state/running_result_state.dart';
import 'package:runlog/repository/running_result_repository.dart';

class RunningResultBloc extends Bloc<RunningResultEvent, RunningResultState> {
  final RunningResultRepository firebaseRepo;

  RunningResultBloc(this.firebaseRepo) : super(RunningResultInitial()) {
    on<SaveRunningResultEvent>(_onSaveResult);
  }

  Future<void> _onSaveResult(
    SaveRunningResultEvent event,
    Emitter<RunningResultState> emit,
  ) async {
    emit(RunningResultSaving());
    try {
      await firebaseRepo.saveResult(
        distance: event.distance,
        duration: event.duration,
      );
      emit(RunningResultSaved());
    } catch (e) {
      emit(RunningResultError('저장 실패: $e'));
    }
  }
}