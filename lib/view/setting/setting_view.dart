import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/event/auth_event.dart';
import 'package:runlog/bloc/state/auth_state.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        }
      },

      child: Scaffold(
        appBar: AppBar(title: Text("설정")),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: const Text("로그아웃"),
            ),
            if (authState is Authenticated) ...[
              SizedBox(height: 10),
              Text('이메일: ${authState.user.email}'),
              Text('이름: ${authState.user.name}'),
            ],
          ],
        ),
      ),
    );
  }
}
