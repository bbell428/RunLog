import 'package:flutter/material.dart';
import 'package:runlog/design.dart';
import 'package:runlog/model/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final String advice;

  const WeatherCard({super.key, required this.weather, required this.advice});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Design.screenWidth(context) * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 40, color: Colors.blue.shade800),
              const SizedBox(height: 12),
              Text(
                weather.cityName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "날씨: ${weather.description}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                "온도: ${weather.temperature.toStringAsFixed(1)}°C",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                "습도: ${weather.humidity}%",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                advice,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}