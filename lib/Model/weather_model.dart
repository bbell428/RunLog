class WeatherModel {
  final String cityName;
  final double temperature;
  final String weatherMain;
  final int humidity;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.weatherMain,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      weatherMain: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
    );
  }
}