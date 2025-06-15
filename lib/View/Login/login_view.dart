import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/event/auth_event.dart';
import 'package:runlog/bloc/state/auth_state.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is Authenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.push('/TabView');
            });
          } else if (state is AuthError) {
            return Center(child: Text(state.message));
          }

          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(GoogleSignInRequested());
              },
              child: const Text("Google 로그인"),
            ),
          );
        },
      ),
    );
  }
}
