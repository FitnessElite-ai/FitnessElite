import 'package:flutter/foundation.dart';

enum BluetoothDeviceState { disconnected, scanning, connecting, connected, error }

/// Service managing Bluetooth fitness equipment and heart rate monitor connections.
class BluetoothFitnessDeviceService {
  BluetoothDeviceState _state = BluetoothDeviceState.disconnected;
  String? _connectedDeviceName;

  BluetoothDeviceState get state => _state;
  String? get connectedDeviceName => _connectedDeviceName;

  Future<void> startScan() async {
    _state = BluetoothDeviceState.scanning;
    debugPrint('[BluetoothFitnessDeviceService] Scanning for Bluetooth fitness devices...');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<bool> connectToDevice(String deviceName) async {
    _state = BluetoothDeviceState.connecting;
    await Future.delayed(const Duration(milliseconds: 200));
    _state = BluetoothDeviceState.connected;
    _connectedDeviceName = deviceName;
    debugPrint('[BluetoothFitnessDeviceService] Connected to $deviceName.');
    return true;
  }

  void disconnect() {
    _state = BluetoothDeviceState.disconnected;
    _connectedDeviceName = null;
  }
}
