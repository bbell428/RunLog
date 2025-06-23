import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/bloc/weather_bloc.dart';
import 'package:runlog/bloc/state/auth_state.dart';
import 'package:runlog/bloc/state/weather_state.dart';
import 'package:runlog/design.dart';
import 'package:runlog/view/home/weather/weather_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/RunLog.png'),
                if (authState is Authenticated) ...[
                  Text(
                    '${authState.user.name}님 환영합니다.',
                    style: TextStyle(
                      fontSize: Design.screenWidth(context) * 0.07,
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                BlocBuilder<WeatherBloc, WeatherState>(
                  builder: (context, state) {
                    if (state is WeatherLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is WeatherLoaded) {
                      return WeatherCard(
                        weather: state.weather,
                        advice: state.advice,
                      );
                    } else if (state is WeatherError) {
                      return Text(
                        '날씨 불러오기 실패: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  '러닝을 시작하려면 아래 버튼을 눌러보세요',
                  style: TextStyle(
                    fontSize: Design.screenWidth(context) * 0.043,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: Design.screenHeight(context) * 0.01),
                SizedBox(
                  width: Design.screenWidth(context) * 0.8,
                  height: Design.screenHeight(context) * 0.08,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => context.push('/runningMap'),
                    child: Text(
                      '러닝하기',
                      style: TextStyle(
                        fontSize: Design.screenWidth(context) * 0.07,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
