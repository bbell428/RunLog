import 'package:runlog/model/weather_model.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  final String advice;

  WeatherLoaded({required this.weather, required this.advice});
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);
}