import '../../../core/services/local_storage_service.dart';
import '../models/device_fitness_data.dart';

abstract class DeviceDataRepository {
  DeviceFitnessData? getLatestDeviceData();
  Future<bool> saveDeviceData(DeviceFitnessData data);
  bool isDeviceConnected();
  Future<bool> setDeviceConnected(bool connected);
}

class LocalDeviceDataRepository implements DeviceDataRepository {
  static const String _keyDeviceData = 'fe_device_latest_data';
  static const String _keyDeviceConnected = 'fe_device_connected_state';

  final LocalStorageService _storage;

  LocalDeviceDataRepository(this._storage);

  @override
  DeviceFitnessData? getLatestDeviceData() {
    final str = _storage.getString(_keyDeviceData);
    if (str != null && str.isNotEmpty) {
      try {
        return DeviceFitnessData.fromJson(str);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<bool> saveDeviceData(DeviceFitnessData data) async {
    return await _storage.setString(_keyDeviceData, data.toJson());
  }

  @override
  bool isDeviceConnected() {
    return _storage.getString(_keyDeviceConnected) == 'true';
  }

  @override
  Future<bool> setDeviceConnected(bool connected) async {
    return await _storage.setString(_keyDeviceConnected, connected ? 'true' : 'false');
  }
}
