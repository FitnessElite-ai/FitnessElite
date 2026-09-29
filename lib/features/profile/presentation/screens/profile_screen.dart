import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/persistence_providers.dart';
import '../../../../core/services/user_data_repository.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../ai_coach/providers/ai_coach_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../devices/ui/screens/device_connection_screen.dart';
import '../../../fitness_engine/providers/fitness_engine_provider.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../../../subscription/providers/subscription_provider.dart';

final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalUserDataRepository(storage);
});

/// Full Profile & Settings Screen with grouped sections.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    final aiState = ref.watch(conversationNotifierProvider);
    final subState = ref.watch(subscriptionNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);

    final hp = aiState.completeProfile?.healthProfile;
    final name = hp?.name ?? 'Athlete';
    final goal = hp?.primaryGoal ?? 'Improve overall fitness';

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
                      // User Info Card
                      GlassEntranceAnimation(
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: const Center(
                                  child: Icon(Icons.person_rounded,
                                      color: Colors.black, size: 28),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Goal: $goal',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.electricBlue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subscription Status Card
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'MEMBERSHIP STATUS',
                                    style: TextStyle(
                                      color: AppColors.electricBlue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subState.isPremium
                                        ? 'Premium Active (${subState.status.name.toUpperCase()})'
                                        : 'Free Plan',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const PaywallScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                ),
                                child: Text(subState.isPremium
                                    ? 'Manage'
                                    : 'Upgrade'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Grouped Section: FITNESSElite AI
                      const Text(
                        'FITNESS AGENT & MEMORY',
                        style: TextStyle(
                          color: AppColors.electricBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _SettingsTile(
                        icon: Icons.psychology_rounded,
                        title: 'My Fitness Memory',
                        subtitle: 'Inspect & edit learned preferences',
                        onTap: () => context.push('/agent-memory'),
                      ),
                      const SizedBox(height: 8),

                      Consumer(
                        builder: (context, ref, child) {
                          final alarmConfig = ref.watch(workoutAlarmNotifierProvider);
                          return _SettingsTile(
                            icon: Icons.alarm_rounded,
                            title: 'Daily Workout Alarm',
                            subtitle: alarmConfig.isEnabled
                                ? 'Alarm set for ${alarmConfig.formattedTime}'
                                : 'Alarm Disabled',
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: alarmConfig.alarmTime,
                              );
                              if (picked != null) {
                                ref.read(workoutAlarmNotifierProvider.notifier).updateTime(picked);
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      _SettingsTile(
                        icon: Icons.watch_rounded,
                        title: 'Connected Devices & Wearables',
                        subtitle: 'Sync Apple Health, Health Connect, or Bluetooth',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DeviceConnectionScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      _SettingsTile(
                        icon: Icons.refresh_rounded,
                        title: 'Regenerate Fitness Plan',
                        subtitle: 'Re-run Fitness Engine with current profile',
                        onTap: () {
                          ref
                              .read(fitnessEngineNotifierProvider.notifier)
                              .resetPlan();
                          context.go('/plan-generation');
                        },
                      ),

                      const SizedBox(height: 20),

                      // Grouped Section: PREFERENCES & SETTINGS
                      const Text(
                        'PREFERENCES & APP',
                        style: TextStyle(
                          color: AppColors.electricBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _SettingsTile(
                        icon: Icons.language_rounded,
                        title: l10n.changeLanguage,
                        subtitle: 'Choose preferred language',
                        onTap: () => context.go('/language-selection'),
                      ),
                      const SizedBox(height: 8),

                      _SettingsTile(
                        icon: isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        title: l10n.switchTheme,
                        subtitle: themeMode.name.toUpperCase(),
                        onTap: () {
                          final nextMode = isDark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(nextMode);
                        },
                      ),
                      const SizedBox(height: 8),

                      _SettingsTile(
                        icon: Icons.download_rounded,
                        title: 'Export My Data',
                        subtitle: 'Export biometric and fitness history logs',
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final jsonExport = await ref
                              .read(userDataRepositoryProvider)
                              .exportUserData();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Data Export Ready (${jsonExport.length} bytes)'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy & Health Data',
                        subtitle: 'Photos and biometric data stay 100% local',
                        onTap: () {},
                      ),

                      const SizedBox(height: 24),

                      // Sign Out Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .signOut();
                            if (context.mounted) {
                              context.go('/auth');
                            }
                          },
                          icon: const Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 18),
                          label: const Text('Sign Out',
                              style: TextStyle(color: AppColors.error)),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.electricBlue.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: AppColors.electricBlue, size: 20),
        ),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 11,
                )),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.electricBlue),
        onTap: onTap,
      ),
    );
  }
}
