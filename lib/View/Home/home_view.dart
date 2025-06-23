import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/event/auth_event.dart';
import 'package:runlog/bloc/state/auth_state.dart';
import 'package:runlog/design.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeView> {
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
        appBar: AppBar(title: Text('러닝')),

        body: Container(
          padding: const EdgeInsets.all(50),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  child: Image.asset('assets/images/running.png'),
                ),
                Text(
                  '마라톤 대비',
                  style: TextStyle(
                    fontSize: Design.screenWidth(context) * 0.08,
                  ),
                ),
                Text(
                  '운동을 시작하려면 아래 버튼을 눌러보세요',
                  style: TextStyle(
                    fontSize: Design.screenWidth(context) * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: Design.screenHeight(context) * 0.02),
                SizedBox(
                  width: Design.screenWidth(context) * 0.6,
                  height: Design.screenHeight(context) * 0.08,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => context.push('/runningMap'), // 스택으로
                    child: Text(
                      '러닝하기',
                      style: TextStyle(
                        fontSize: Design.screenWidth(context) * 0.07,
                      ),
                    ),
                  ),
                ),
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
                SizedBox(height: Design.screenHeight(context) * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
