import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/bloc/running_result_bloc.dart';
import 'package:runlog/bloc/event/running_result_event.dart';
import 'package:runlog/bloc/state/auth_state.dart';
import 'package:runlog/bloc/state/running_result_state.dart';

class RunningResultView extends StatelessWidget {
  final double distance; // km
  final Duration duration;

  const RunningResultView({
    super.key,
    required this.distance,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(title: Text('런닝 결과')),
      body: BlocListener<RunningResultBloc, RunningResultState>(
        listener: (context, state) {
          if (state is RunningResultSaved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('기록 완료')));
            context.go('/tabView');
          } else if (state is RunningResultError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Column(
          children: [
            Text('거리: ${distance.toStringAsFixed(2)} m'),
            Text('시간: ${duration.inMinutes}분 ${duration.inSeconds % 60}초'),
            ElevatedButton(
              onPressed: () {
                if (authState is Authenticated) {
                  context.read<RunningResultBloc>().add(
                    SaveRunningResultEvent(
                      uid: authState.user.uid,
                      distance: distance,
                      duration: duration,
                    ),
                  );
                }
              },
              child: const Text("기록하기"),
            ),
          ],
        ),
      ),
    );
  }
}
