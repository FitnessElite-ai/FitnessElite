import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/subscription_state.dart';

/// Clean service wrapper for RevenueCat (purchases_flutter).
class SubscriptionService {
  static const String entitlementId = 'fitness_elite_premium';

  Future<void> initialize(String apiKey) async {
    if (apiKey.isEmpty || apiKey == 'REVENUECAT_API_KEY_PLACEHOLDER') {
      debugPrint('[SubscriptionService] RevenueCat API Key unconfigured. Operating in dev mode.');
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);
      PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
    } catch (e) {
      debugPrint('[SubscriptionService] Purchases.configure error: $e');
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[SubscriptionService] getOfferings error: $e');
      return null;
    }
  }

  Future<SubscriptionState> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];

      if (entitlement != null && entitlement.isActive) {
        final isTrial = entitlement.periodType == PeriodType.trial;
        return SubscriptionState(
          status: isTrial ? SubscriptionStatus.trial : SubscriptionStatus.active,
          entitlementId: entitlementId,
          activePackageId: entitlement.productIdentifier,
          expirationDate: entitlement.expirationDate != null
              ? DateTime.parse(entitlement.expirationDate!)
              : null,
        );
      }
    } catch (e) {
      debugPrint('[SubscriptionService] getCustomerInfo error: $e');
    }

    return const SubscriptionState(status: SubscriptionStatus.free);
  }

  Future<SubscriptionState> purchasePackage(Package package) async {
    try {
      final dynamic customerInfo = await Purchases.purchase(PurchaseParams.package(package));
      final entitlement = customerInfo.entitlements.all[entitlementId];

      if (entitlement != null && entitlement.isActive) {
        final isTrial = entitlement.periodType == PeriodType.trial;
        return SubscriptionState(
          status: isTrial ? SubscriptionStatus.trial : SubscriptionStatus.active,
          entitlementId: entitlementId,
          activePackageId: package.identifier,
        );
      }
    } catch (e) {
      return SubscriptionState(
        status: SubscriptionStatus.error,
        errorMessage: 'Purchase cancelled or failed: $e',
      );
    }

    return const SubscriptionState(status: SubscriptionStatus.free);
  }

  Future<SubscriptionState> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final entitlement = customerInfo.entitlements.all[entitlementId];

      if (entitlement != null && entitlement.isActive) {
        return SubscriptionState(
          status: SubscriptionStatus.active,
          entitlementId: entitlementId,
        );
      }
    } catch (e) {
      return SubscriptionState(
        status: SubscriptionStatus.error,
        errorMessage: 'Failed to restore purchases: $e',
      );
    }

    return const SubscriptionState(status: SubscriptionStatus.free);
  }
}
