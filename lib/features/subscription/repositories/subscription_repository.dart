import '../../../core/services/local_storage_service.dart';
import '../models/subscription_state.dart';

abstract class SubscriptionRepository {
  SubscriptionStatus getStatus();
  Future<bool> saveStatus(SubscriptionStatus status);
}

class LocalSubscriptionRepository implements SubscriptionRepository {
  static const String _keySubscriptionStatus = 'fe_subscription_status';

  final LocalStorageService _storage;

  LocalSubscriptionRepository(this._storage);

  @override
  SubscriptionStatus getStatus() {
    final str = _storage.getString(_keySubscriptionStatus);
    if (str != null) {
      return SubscriptionStatus.values.firstWhere(
        (e) => e.name == str,
        orElse: () => SubscriptionStatus.free,
      );
    }
    return SubscriptionStatus.free;
  }

  @override
  Future<bool> saveStatus(SubscriptionStatus status) async {
    return await _storage.setString(_keySubscriptionStatus, status.name);
  }
}
