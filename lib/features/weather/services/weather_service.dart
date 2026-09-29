import 'package:flutter/foundation.dart';
import '../models/weather_fitness_data.dart';

/// Location-based weather service retrieving localized environmental signals for adaptive workout decisions.
class WeatherService {
  WeatherFitnessData? _cachedData;

  Future<WeatherFitnessData> fetchLocationWeather({
    String cityName = 'San Francisco',
    double lat = 37.7749,
    double lon = -122.4194,
  }) async {
    debugPrint('[WeatherService] Fetching location-based weather for $cityName ($lat, $lon)...');
    // Default baseline weather
    _cachedData = WeatherFitnessData(
      cityName: cityName,
      temperatureCelsius: 22.0,
      condition: 'Sunny',
      humidityPercentage: 48,
      uvIndex: 4,
      timestamp: DateTime.now(),
    );
    return _cachedData!;
  }

  /// Simulate rain alert scenario for location-based testing
  Future<WeatherFitnessData> simulateRainAlert({String cityName = 'San Francisco'}) async {
    _cachedData = WeatherFitnessData(
      cityName: cityName,
      temperatureCelsius: 16.0,
      condition: 'Heavy Rain',
      humidityPercentage: 88,
      uvIndex: 1,
      timestamp: DateTime.now(),
    );
    return _cachedData!;
  }

  WeatherFitnessData? get cachedData => _cachedData;
}
