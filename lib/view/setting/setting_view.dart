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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("설정")),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 사용자 정보 카드
                if (state is Authenticated)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // const CircleAvatar(
                          //   radius: 30,
                          //   backgroundImage: AssetImage('assets/images/RunLog.png'),
                          // ),
                          // const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.user.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.user.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // 계정
                const Text(
                  "계정",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("로그아웃"),
                  onTap: () {
                    context.read<AuthBloc>().add(SignOutRequested());
                  },
                ),

                const SizedBox(height: 30),

                // 앱 정보
                const Text(
                  "앱 정보",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("앱 이름"),
                  subtitle: const Text("RunLog"),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text("설명"),
                  subtitle: const Text(
                    "러닝 기록 및 날씨 기반 운동 권장 앱",
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: const Text("버전"),
                  subtitle: const Text("1.0.0"),
                ),

                const SizedBox(height: 60),

                // 문의 이메일
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "문의: 428bbell@gmail.com",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
