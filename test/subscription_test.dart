import 'package:fitness_elite/core/services/local_storage_service.dart';
import 'package:fitness_elite/core/services/persistence_providers.dart';
import 'package:fitness_elite/features/subscription/models/subscription_state.dart';
import 'package:fitness_elite/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:fitness_elite/features/subscription/providers/subscription_provider.dart';
import 'package:fitness_elite/features/subscription/repositories/subscription_repository.dart';
import 'package:fitness_elite/features/subscription/widgets/premium_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RevenueCat Subscriptions & Premium Entitlements Tests', () {
    test('SubscriptionState model getters and defaults', () {
      const state = SubscriptionState(status: SubscriptionStatus.free);
      expect(state.isPremium, isFalse);

      const trialState = SubscriptionState(status: SubscriptionStatus.trial);
      expect(trialState.isPremium, isTrue);

      const activeState = SubscriptionState(status: SubscriptionStatus.active);
      expect(activeState.isPremium, isTrue);
    });

    test('LocalSubscriptionRepository persists subscription status', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final repo = LocalSubscriptionRepository(storage);

      expect(repo.getStatus(), equals(SubscriptionStatus.free));

      await repo.saveStatus(SubscriptionStatus.trial);
      expect(repo.getStatus(), equals(SubscriptionStatus.trial));

      await repo.saveStatus(SubscriptionStatus.active);
      expect(repo.getStatus(), equals(SubscriptionStatus.active));
    });

    testWidgets('SubscriptionNotifier toggles free to trial/premium', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );

      final notifier = container.read(subscriptionNotifierProvider.notifier);
      expect(container.read(subscriptionNotifierProvider).isPremium, isFalse);

      notifier.activateDevTrial();
      expect(container.read(subscriptionNotifierProvider).isPremium, isTrue);
      expect(container.read(subscriptionNotifierProvider).status, equals(SubscriptionStatus.trial));
    });

    testWidgets('PremiumGate displays child when premium and prompt when free', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumGate(
                child: Text('Unlocked Premium Content'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially free -> shows paywall prompt
      expect(find.text('Premium Feature'), findsOneWidget);
      expect(find.text('Unlocked Premium Content'), findsNothing);

      // Activate trial
      container.read(subscriptionNotifierProvider.notifier).activateDevTrial();
      await tester.pumpAndSettle();

      expect(find.text('Unlocked Premium Content'), findsOneWidget);
    });

    testWidgets('PaywallScreen renders benefits, 3-day trial offer, and pricing options', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: PaywallScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('FitnessElite.ai Premium'), findsOneWidget);
      expect(find.text('3-DAY FREE TRIAL INCLUDED'), findsOneWidget);
      expect(find.text('\$89 / year'), findsOneWidget);
      expect(find.text('\$9 / month'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
