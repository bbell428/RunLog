import 'package:flutter/material.dart';
import 'package:runlog/design.dart';
import 'package:runlog/model/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final String advice;

  const WeatherCard({super.key, required this.weather, required this.advice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12), // Card 간 여백
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Design.screenWidth(context) * 0.9,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
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
                    Icon(
                      Icons.location_on,
                      size: 36,
                      color: Colors.blue.shade800,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.cityName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                    const SizedBox(height: 12),
                    _WeatherInfoRow(label: "날씨", value: weather.description),
                    _WeatherInfoRow(
                      label: "온도",
                      value: "${weather.temperature.toStringAsFixed(1)}°C",
                    ),
                    _WeatherInfoRow(label: "습도", value: "${weather.humidity}%"),
                    const SizedBox(height: 20),
                    Text(
                      advice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeatherInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _WeatherInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 18),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
