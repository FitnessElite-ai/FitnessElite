import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/persistence_providers.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/device_fitness_data.dart';
import '../../repositories/device_data_repository.dart';
import '../../services/device_integration_service.dart';

final deviceDataRepositoryProvider = Provider<DeviceDataRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalDeviceDataRepository(storage);
});

final deviceIntegrationServiceProvider = Provider<DeviceIntegrationService>((ref) {
  final repo = ref.watch(deviceDataRepositoryProvider);
  return DeviceIntegrationService(repo);
});

class DeviceNotifier extends Notifier<DeviceFitnessData?> {
  late final DeviceDataRepository _repo;
  late final DeviceIntegrationService _service;

  @override
  DeviceFitnessData? build() {
    _repo = ref.watch(deviceDataRepositoryProvider);
    _service = ref.watch(deviceIntegrationServiceProvider);
    return _repo.getLatestDeviceData();
  }

  bool get isConnected => _repo.isDeviceConnected();

  Future<void> connect(String provider) async {
    await _service.connectDevice(provider);
    state = _repo.getLatestDeviceData();
  }

  Future<void> disconnect() async {
    await _service.disconnectDevice();
    state = null;
  }
}

final deviceNotifierProvider = NotifierProvider<DeviceNotifier, DeviceFitnessData?>(
  DeviceNotifier.new,
);

/// Screen enabling users to connect HealthKit, Google Health Connect, or Bluetooth fitness trackers.
class DeviceConnectionScreen extends ConsumerWidget {
  const DeviceConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final notifier = ref.read(deviceNotifierProvider.notifier);
    final latestData = ref.watch(deviceNotifierProvider);
    final isConnected = notifier.isConnected;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(iconSize: 26, fontSize: 18),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeInAnimation(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CONNECTED DEVICES',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sync wearable signals to optimize your daily training plan.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Apple Health / Google Health Connect Card
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        enableGlow: isConnected,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.electricBlue.withValues(alpha: 0.15),
                                  ),
                                  child: const Icon(Icons.favorite_rounded,
                                      color: AppColors.electricBlue, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Apple Health / Google Health Connect',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        isConnected ? 'Connected • Live Sync' : 'Not Connected',
                                        style: TextStyle(
                                          color: isConnected
                                              ? Colors.greenAccent
                                              : (isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.lightTextSecondary),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (isConnected && latestData != null) ...[
                              const SizedBox(height: 14),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _DeviceMetric('STEPS', '${latestData.steps}'),
                                  _DeviceMetric('SLEEP', '${latestData.sleepDurationHours} hrs'),
                                  _DeviceMetric('REST HR', '${latestData.restingHeartRate} bpm'),
                                ],
                              ),
                            ],
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: isConnected
                                  ? OutlinedButton(
                                      onPressed: () => notifier.disconnect(),
                                      child: const Text('Disconnect'),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => notifier.connect('Apple Health / Health Connect'),
                                      child: const Text('Connect Device'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceMetric extends StatelessWidget {
  final String label;
  final String value;
  const _DeviceMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.electricBlue,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
