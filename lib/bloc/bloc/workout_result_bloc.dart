import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runlog/bloc/event/workout_result_event.dart';
import 'package:runlog/bloc/state/workout_result_state.dart';
import 'package:runlog/repository/running_result_repository.dart';

class WorkoutResultBloc extends Bloc<WorkoutResultEvent, WorkoutResultState> {
  final FirebaseRunningRepository repo;

  WorkoutResultBloc(this.repo) : super(WorkoutResultInitial()) {
    on<LoadWorkoutResults>(_onLoad);
    on<DeleteWorkoutResult>(_onDelete);
  }

  Future<void> _onLoad(
    LoadWorkoutResults event,
    Emitter<WorkoutResultState> emit,
  ) async {
    emit(WorkoutResultLoading());
    try {
      final results = await repo.fetchRunningResults(event.uid);
      emit(WorkoutResultLoaded(results));
    } catch (e) {
      emit(WorkoutResultError('불러오기 실패: $e'));
    }
  }

  Future<void> _onDelete(
    DeleteWorkoutResult event,
    Emitter<WorkoutResultState> emit,
  ) async {
    try {
      await repo.deleteResult(uid: event.uid, docId: event.docId);
      final results = await repo.fetchRunningResults(event.uid);
      emit(WorkoutResultLoaded(results));
    } catch (e) {
      emit(WorkoutResultError('삭제 실패: $e'));
    }
  }
}
