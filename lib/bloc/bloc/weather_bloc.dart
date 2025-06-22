import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runlog/bloc/event/weather_event.dart';
import 'package:runlog/bloc/state/weather_state.dart';
import 'package:runlog/repository/weather_repository.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository repository;

  WeatherBloc(this.repository) : super(WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
  }

  void _onFetchWeather(FetchWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());

    try {
      final position = await repository.getCurrentPosition();
      final weather = await repository.fetchWeather(
        position.latitude,
        position.longitude,
      );

      final advice = _getRunningAdvice(
        weather.description,
        weather.temperature,
        weather.humidity,
      );

      emit(WeatherLoaded(weather: weather, advice: advice));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  String _getRunningAdvice(String description, double temp, int humidity) {
    final desc = description.toLowerCase();

    if (desc.contains("비") ||
        desc.contains("눈") ||
        desc.contains("소나기")) {
      return "⛔ 오늘은 비/눈이 와요. 실내 러닝을 추천해요.";
    } else if (temp >= 30) {
      return "🥵 너무 더워요! 수분 보충하며 조심히 달려요.";
    } else if (temp <= 0) {
      return "🥶 너무 추워요! 방한 준비 후 조심히 달려요.";
    } else if (humidity > 80) {
      return "💧 습도가 높아요. 무리하지 마세요.";
    } else {
      return "🏃‍♂️ 날씨 좋아요! 러닝하기 딱 좋네요!";
    }
  }
}
