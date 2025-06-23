import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/bloc/running_result_bloc.dart';
import 'package:runlog/bloc/event/running_result_event.dart';
import 'package:runlog/bloc/state/auth_state.dart';
import 'package:runlog/bloc/state/running_result_state.dart';
import 'package:runlog/design.dart';

class RunningResultView extends StatelessWidget {
  final double distance; // meters 단위로 받음
  final Duration duration;

  const RunningResultView({
    super.key,
    required this.distance,
    required this.duration,
  });

  String _formatPace() {
    final distanceKm = distance / 1000;
    if (distanceKm == 0) return '-';
    final paceSeconds = duration.inSeconds / distanceKm;
    final minutes = paceSeconds ~/ 60;
    final seconds = (paceSeconds % 60).round();
    return "$minutes'${seconds.toString().padLeft(2, '0')}\" /km";
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('러닝 결과')),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/running.png', height: 180),
                const SizedBox(height: 30),
                _InfoRow(
                  icon: Icons.place,
                  label: '거리',
                  value:
                      distance >= 1000
                          ? '${(distance / 1000).toStringAsFixed(2)} km'
                          : '${distance.toStringAsFixed(0)} m',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.timer,
                  label: '시간',
                  value: '${duration.inMinutes}분 ${duration.inSeconds % 60}초',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.speed,
                  label: '평균 페이스',
                  value: _formatPace(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width:  Design.screenWidth(context) * 0.7,
                  child: ElevatedButton(
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text("기록하기", style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
                SizedBox(height: Design.screenHeight(context) * 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ],
    );
  }
}
