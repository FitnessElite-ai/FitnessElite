import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/breathing_exercise.dart';

enum BreathPhase { preparing, inhaling, holdAfterInhale, exhaling, holdAfterExhale, paused, completed, stopped }

class BreathingSessionState {
  final BreathPhase phase;
  final int currentCycle;
  final int totalCycles;
  final int phaseSecondsRemaining;
  final int totalSecondsRemaining;

  const BreathingSessionState({
    this.phase = BreathPhase.preparing,
    this.currentCycle = 1,
    required this.totalCycles,
    this.phaseSecondsRemaining = 3,
    required this.totalSecondsRemaining,
  });

  String get phaseLabel {
    switch (phase) {
      case BreathPhase.preparing:
        return 'Get Ready';
      case BreathPhase.inhaling:
        return 'Breathe In';
      case BreathPhase.holdAfterInhale:
        return 'Hold';
      case BreathPhase.exhaling:
        return 'Breathe Out';
      case BreathPhase.holdAfterExhale:
        return 'Hold';
      case BreathPhase.paused:
        return 'Paused';
      case BreathPhase.completed:
        return 'Complete!';
      case BreathPhase.stopped:
        return 'Stopped';
    }
  }
}

/// Deterministic session engine driving accurate breathing phase timers without relying on LLMs.
class BreathingSessionEngine {
  final BreathingExercise exercise;
  final ValueChanged<BreathingSessionState> onTick;

  Timer? _timer;
  late BreathPhase _currentPhase;
  int _currentCycle = 1;
  int _phaseSecondsRemaining = 3; // 3s preparation count
  int _totalSecondsRemaining = 0;
  bool _isPaused = false;

  BreathingSessionEngine({
    required this.exercise,
    required this.onTick,
  }) {
    _totalSecondsRemaining = exercise.durationSeconds;
    _currentPhase = BreathPhase.preparing;
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => _tick());
    _notify();
  }

  void pause() {
    _isPaused = true;
    _notify();
  }

  void resume() {
    _isPaused = false;
    _notify();
  }

  void stop() {
    _timer?.cancel();
    _currentPhase = BreathPhase.stopped;
    _notify();
  }

  void _tick() {
    if (_isPaused || _currentPhase == BreathPhase.completed || _currentPhase == BreathPhase.stopped) {
      return;
    }

    if (_totalSecondsRemaining > 0) {
      _totalSecondsRemaining--;
    }

    _phaseSecondsRemaining--;

    if (_phaseSecondsRemaining <= 0) {
      _transitionToNextPhase();
    }

    _notify();
  }

  void _transitionToNextPhase() {
    switch (_currentPhase) {
      case BreathPhase.preparing:
        _currentPhase = BreathPhase.inhaling;
        _phaseSecondsRemaining = exercise.inhaleSeconds;
        break;

      case BreathPhase.inhaling:
        if (exercise.holdAfterInhaleSeconds > 0) {
          _currentPhase = BreathPhase.holdAfterInhale;
          _phaseSecondsRemaining = exercise.holdAfterInhaleSeconds;
        } else {
          _currentPhase = BreathPhase.exhaling;
          _phaseSecondsRemaining = exercise.exhaleSeconds;
        }
        break;

      case BreathPhase.holdAfterInhale:
        _currentPhase = BreathPhase.exhaling;
        _phaseSecondsRemaining = exercise.exhaleSeconds;
        break;

      case BreathPhase.exhaling:
        if (exercise.holdAfterExhaleSeconds > 0) {
          _currentPhase = BreathPhase.holdAfterExhale;
          _phaseSecondsRemaining = exercise.holdAfterExhaleSeconds;
        } else if (_currentCycle < exercise.cycles) {
          _currentCycle++;
          _currentPhase = BreathPhase.inhaling;
          _phaseSecondsRemaining = exercise.inhaleSeconds;
        } else {
          _currentPhase = BreathPhase.completed;
          _timer?.cancel();
        }
        break;

      case BreathPhase.holdAfterExhale:
        if (_currentCycle < exercise.cycles) {
          _currentCycle++;
          _currentPhase = BreathPhase.inhaling;
          _phaseSecondsRemaining = exercise.inhaleSeconds;
        } else {
          _currentPhase = BreathPhase.completed;
          _timer?.cancel();
        }
        break;

      case BreathPhase.paused:
      case BreathPhase.completed:
      case BreathPhase.stopped:
        break;
    }
  }

  void _notify() {
    onTick(
      BreathingSessionState(
        phase: _currentPhase,
        currentCycle: _currentCycle,
        totalCycles: exercise.cycles,
        phaseSecondsRemaining: _phaseSecondsRemaining,
        totalSecondsRemaining: _totalSecondsRemaining,
      ),
    );
  }

  void dispose() {
    _timer?.cancel();
  }
}
