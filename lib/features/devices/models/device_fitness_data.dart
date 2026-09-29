import 'dart:convert';

/// Normalized wearable and Bluetooth fitness device signal data.
class DeviceFitnessData {
  final String source; // e.g. "Apple Health", "Google Health Connect", "Smart Scale", "Heart Rate Monitor"
  final int steps;
  final int heartRate; // BPM
  final int restingHeartRate; // BPM
  final double sleepDurationHours;
  final int activeCalories;
  final double weightKg;
  final DateTime timestamp;

  const DeviceFitnessData({
    required this.source,
    this.steps = 0,
    this.heartRate = 0,
    this.restingHeartRate = 0,
    this.sleepDurationHours = 0.0,
    this.activeCalories = 0,
    this.weightKg = 0.0,
    required this.timestamp,
  });

  bool get hasPoorSleepSignal => sleepDurationHours > 0 && sleepDurationHours < 6.0;
  bool get hasElevatedHeartRateSignal => restingHeartRate > 75;

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'steps': steps,
      'heartRate': heartRate,
      'restingHeartRate': restingHeartRate,
      'sleepDurationHours': sleepDurationHours,
      'activeCalories': activeCalories,
      'weightKg': weightKg,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DeviceFitnessData.fromMap(Map<String, dynamic> map) {
    return DeviceFitnessData(
      source: map['source'] as String? ?? 'Device',
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      heartRate: (map['heartRate'] as num?)?.toInt() ?? 0,
      restingHeartRate: (map['restingHeartRate'] as num?)?.toInt() ?? 0,
      sleepDurationHours: (map['sleepDurationHours'] as num?)?.toDouble() ?? 0.0,
      activeCalories: (map['activeCalories'] as num?)?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceFitnessData.fromJson(String source) =>
      DeviceFitnessData.fromMap(json.decode(source) as Map<String, dynamic>);
}
