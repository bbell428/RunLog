import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/event/auth_event.dart';
import 'package:runlog/bloc/state/auth_state.dart';
import 'package:runlog/design.dart';

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
              context.go('/tabView');
            });
          } else if (state is AuthError) {
            return Center(child: Text(state.message));
          }

          return Container(
            padding: const EdgeInsets.all(80),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/running.png', height: 180),
                  const Text(
                    'RunLog',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '러닝 기록을 안전하게 저장하고\n확인하려면 로그인해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Material(
                    color: Colors.transparent, // 배경이 비치게
                    child: InkWell(
                      onTap: () {
                        context.read<AuthBloc>().add(GoogleSignInRequested());
                      },
                      child: Ink(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset('assets/images/GoogleLogin.png'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Design.screenHeight(context) * 0.1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
