enum VoiceStatus { idle, listening, understanding, responding, error }

class VoiceState {
  final VoiceStatus status;
  final String transcript;
  final String responseText;
  final String? errorMessage;

  const VoiceState({
    this.status = VoiceStatus.idle,
    this.transcript = '',
    this.responseText = '',
    this.errorMessage,
  });

  VoiceState copyWith({
    VoiceStatus? status,
    String? transcript,
    String? responseText,
    String? errorMessage,
  }) {
    return VoiceState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      responseText: responseText ?? this.responseText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
