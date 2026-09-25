import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/services/persistence_providers.dart';
import '../models/subscription_state.dart';
import '../repositories/subscription_repository.dart';
import '../services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalSubscriptionRepository(storage);
});

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  late final SubscriptionService _service;
  late final SubscriptionRepository _repository;

  @override
  SubscriptionState build() {
    _service = ref.watch(subscriptionServiceProvider);
    _repository = ref.watch(subscriptionRepositoryProvider);

    final savedStatus = _repository.getStatus();
    return SubscriptionState(status: savedStatus);
  }

  Future<void> checkSubscriptionStatus() async {
    state = state.copyWith(status: SubscriptionStatus.loading);
    final newState = await _service.checkSubscriptionStatus();
    _repository.saveStatus(newState.status);
    state = newState;
  }

  Future<bool> purchasePackage(Package package) async {
    state = state.copyWith(status: SubscriptionStatus.loading);
    final newState = await _service.purchasePackage(package);
    _repository.saveStatus(newState.status);
    state = newState;
    return newState.isPremium;
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(status: SubscriptionStatus.loading);
    final newState = await _service.restorePurchases();
    _repository.saveStatus(newState.status);
    state = newState;
    return newState.isPremium;
  }

  void activateDevTrial() {
    state = const SubscriptionState(status: SubscriptionStatus.trial);
    _repository.saveStatus(SubscriptionStatus.trial);
  }
}

final subscriptionNotifierProvider = NotifierProvider<
    SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
