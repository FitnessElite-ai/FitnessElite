enum SubscriptionStatus { loading, free, trial, active, expired, cancelled, error }

/// Model representing user's RevenueCat entitlement & subscription state.
class SubscriptionState {
  final SubscriptionStatus status;
  final String entitlementId;
  final String activePackageId;
  final DateTime? expirationDate;
  final String? errorMessage;

  const SubscriptionState({
    this.status = SubscriptionStatus.free,
    this.entitlementId = 'fitness_elite_premium',
    this.activePackageId = '',
    this.expirationDate,
    this.errorMessage,
  });

  bool get isPremium =>
      status == SubscriptionStatus.trial || status == SubscriptionStatus.active;

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    String? entitlementId,
    String? activePackageId,
    DateTime? expirationDate,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      entitlementId: entitlementId ?? this.entitlementId,
      activePackageId: activePackageId ?? this.activePackageId,
      expirationDate: expirationDate ?? this.expirationDate,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
