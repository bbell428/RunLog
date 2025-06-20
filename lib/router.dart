import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/View/Home/Running_map_view.dart';
import 'package:runlog/View/Home/running_result_view.dart';
import 'package:runlog/View/Login/login_view.dart';
import 'package:runlog/View/Home/home_view.dart';
import 'package:runlog/View/Marathon/marathon_view.dart';
import 'package:runlog/View/Workout/workout_view.dart';
import 'package:runlog/bloc/bloc/running_map_bloc.dart';
import 'package:runlog/bloc/event/running_map_event.dart';
import 'package:runlog/main_tab_View.dart';

// 라우터 관리(go_router)
final GoRouter goRouter = GoRouter(
  initialLocation: '/login', // 앱이 시작될 때 처음 보여줄 경로(화면)
  debugLogDiagnostics: true, // 라우팅 디버깅 로그 활성화
  routes: <RouteBase>[
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),

    // 탭뷰 화면(초기)
    GoRoute(path: '/tabView', builder: (context, state) => const MainTabView()),

    // 홈 화면
    GoRoute(path: '/home', builder: (context, state) => const HomeView()),

    // 런닝 맵 화면
    GoRoute(path: '/runningMap', builder: (context, state) => const RunningMapView()),

    // 런닝 결과 화면
    GoRoute(
      path: '/runningResult',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return RunningResultView(
          distance: data['distance'] as double,
          duration: data['duration'] as Duration,
        );
      },
    ),

    // 기록 화면
    GoRoute(path: '/workout', builder: (context, state) => const WorkoutView()),

    // 마라톤 일정 화면
    GoRoute(
      path: '/marathon',
      builder: (context, state) => const MarathonView(),
    ),
  ],
);
