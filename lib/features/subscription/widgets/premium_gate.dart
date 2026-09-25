import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/screens/paywall_screen.dart';
import '../providers/subscription_provider.dart';

/// Centralized widget for guarding premium-only features.
/// Renders child if premium/trial is active; otherwise displays paywall prompt.
class PremiumGate extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const PremiumGate({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionNotifierProvider);

    if (subState.isPremium) {
      return child;
    }

    if (fallback != null) {
      return fallback!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            const Text(
              'Premium Feature',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Start your 3-day free trial to access this feature.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
              },
              child: const Text('Start 3-Day Free Trial'),
            ),
          ],
        ),
      ),
    );
  }
}
