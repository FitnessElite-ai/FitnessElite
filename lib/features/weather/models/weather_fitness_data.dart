import 'dart:convert';

/// Normalized location-based weather and environmental signal data for workout adaptations.
class WeatherFitnessData {
  final String cityName;
  final double temperatureCelsius;
  final String condition; // e.g. "Sunny", "Partly Cloudy", "Rain", "Thunderstorm", "Extreme Heat", "Heavy Snow"
  final int humidityPercentage;
  final int uvIndex;
  final DateTime timestamp;

  const WeatherFitnessData({
    required this.cityName,
    required this.temperatureCelsius,
    required this.condition,
    this.humidityPercentage = 50,
    this.uvIndex = 3,
    required this.timestamp,
  });

  bool get isOutdoorFriendly {
    final cond = condition.toLowerCase();
    if (cond.contains('rain') ||
        cond.contains('storm') ||
        cond.contains('snow') ||
        cond.contains('extreme heat') ||
        temperatureCelsius > 35.0 ||
        temperatureCelsius < 0.0) {
      return false;
    }
    return true;
  }

  bool get hasWeatherAlert => !isOutdoorFriendly;

  String get alertMessage {
    if (condition.toLowerCase().contains('rain') || condition.toLowerCase().contains('storm')) {
      return 'Rain alert in $cityName. Recommending indoor training.';
    }
    if (temperatureCelsius > 35.0 || condition.toLowerCase().contains('extreme heat')) {
      return 'Extreme Heat ($temperatureCelsius°C) in $cityName. Stay hydrated & train indoors.';
    }
    if (temperatureCelsius < 0.0 || condition.toLowerCase().contains('snow')) {
      return 'Freezing temperature ($temperatureCelsius°C) in $cityName. Indoor warmup recommended.';
    }
    return '$condition ($temperatureCelsius°C) in $cityName.';
  }

  Map<String, dynamic> toMap() {
    return {
      'cityName': cityName,
      'temperatureCelsius': temperatureCelsius,
      'condition': condition,
      'humidityPercentage': humidityPercentage,
      'uvIndex': uvIndex,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WeatherFitnessData.fromMap(Map<String, dynamic> map) {
    return WeatherFitnessData(
      cityName: map['cityName'] as String? ?? 'Your Location',
      temperatureCelsius: (map['temperatureCelsius'] as num?)?.toDouble() ?? 22.0,
      condition: map['condition'] as String? ?? 'Sunny',
      humidityPercentage: (map['humidityPercentage'] as num?)?.toInt() ?? 50,
      uvIndex: (map['uvIndex'] as num?)?.toInt() ?? 3,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory WeatherFitnessData.fromJson(String source) =>
      WeatherFitnessData.fromMap(json.decode(source) as Map<String, dynamic>);
}
