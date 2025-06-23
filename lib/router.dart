import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/view/Home/Running_map_view.dart';
import 'package:runlog/view/home/running_result_view.dart';
import 'package:runlog/view/login/login_view.dart';
import 'package:runlog/view/home/home_view.dart';
import 'package:runlog/view/home/weather/weather_view.dart';
import 'package:runlog/view/workout/workout_result_view.dart';
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
    GoRoute(
      path: '/runningMap',
      builder: (context, state) {
        return BlocProvider(
          create:
              (context) =>
                  RunningMapBloc()
                    ..add(GetCurrentLocationRequested()), // 뷰로 들어갈 때마다 초기화
          child: const RunningMapView(),
        );
      },
    ),

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
    GoRoute(
      path: '/workout',
      builder: (context, state) => const WorkoutResultView(),
    ),

    // 날씨 화면
    GoRoute(
      path: '/weather',
      builder: (context, state) => const WeatherView(),
    ),
  ],
);
