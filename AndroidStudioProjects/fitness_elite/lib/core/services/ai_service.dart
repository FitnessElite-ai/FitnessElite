import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AiServiceStatus { uninitialized, initializing, ready, error }

/// Asynchronous, lazy-loading AI Service foundation for FitnessElite.ai.
/// Ensures AI engine initialization is non-blocking, occurs lazily when
/// accessing AI features, and provides graceful error/retry states.
class AiServiceState {
  final AiServiceStatus status;
  final String? errorMessage;

  const AiServiceState({
    this.status = AiServiceStatus.uninitialized,
    this.errorMessage,
  });

  AiServiceState copyWith({
    AiServiceStatus? status,
    String? errorMessage,
  }) {
    return AiServiceState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AiServiceNotifier extends Notifier<AiServiceState> {
  @override
  AiServiceState build() {
    return const AiServiceState(status: AiServiceStatus.uninitialized);
  }

  /// Lazily initializes AI engine asynchronously without blocking the UI thread.
  Future<void> initializeLazily() async {
    if (state.status == AiServiceStatus.ready ||
        state.status == AiServiceStatus.initializing) {
      return;
    }

    state = state.copyWith(status: AiServiceStatus.initializing, errorMessage: null);

    try {
      // Async background task simulation (e.g. loading models/weights asynchronously)
      await Future<void>.delayed(const Duration(milliseconds: 300));

      state = state.copyWith(status: AiServiceStatus.ready);
    } catch (e, stack) {
      debugPrint('AI Service initialization failed: $e\n$stack');
      state = state.copyWith(
        status: AiServiceStatus.error,
        errorMessage: 'Unable to connect to AI engine. Tap to retry.',
      );
    }
  }

  void retryInitialization() {
    state = const AiServiceState(status: AiServiceStatus.uninitialized);
    initializeLazily();
  }
}

final aiServiceProvider =
    NotifierProvider<AiServiceNotifier, AiServiceState>(
  AiServiceNotifier.new,
);
