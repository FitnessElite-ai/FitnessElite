import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../providers/subscription_provider.dart';

/// Premium Paywall Screen highlighting "UNLOCK YOUR PERSONAL FITNESS AGENT", Benefits, $9/mo or $89/yr selection, and RevenueCat integration.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isAnnualSelected = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final notifier = ref.read(subscriptionNotifierProvider.notifier);

    final benefits = const [
      'Adaptive workouts',
      'Personal AI Coach',
      'Advanced progress intelligence',
      'Nutrition guidance',
      'Recovery intelligence',
      'Vision-assisted personalization',
      'Long-term fitness memory',
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
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
                    children: [
                      GlassEntranceAnimation(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.electricBlue.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.electricBlue),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 16, color: AppColors.electricBlue),
                              SizedBox(width: 6),
                              Text(
                                '3-DAY FREE TRIAL INCLUDED',
                                style: TextStyle(
                                  color: AppColors.electricBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      FadeInAnimation(
                        child: Column(
                          children: [
                            Text(
                              'UNLOCK YOUR PERSONAL FITNESS AGENT',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'FitnessElite.ai Premium',
                              style: TextStyle(
                                color: AppColors.electricBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Continuous AI learning and real-time plan adaptations.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Benefits List Card
                      GlassEntranceAnimation(
                        child: GlassCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: benefits.map((b) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        size: 18, color: AppColors.electricBlue),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        b,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Subscription Options Selector
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isAnnualSelected = true),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                enableGlow: _isAnnualSelected,
                                child: Column(
                                  children: const [
                                    Text(
                                      'ANNUAL',
                                      style: TextStyle(
                                        color: AppColors.electricBlue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$89 / year',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'Save 18%',
                                      style: TextStyle(
                                        color: AppColors.electricBlue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isAnnualSelected = false),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                enableGlow: !_isAnnualSelected,
                                child: Column(
                                  children: const [
                                    Text(
                                      'MONTHLY',
                                      style: TextStyle(
                                        color: AppColors.electricBlue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$9 / month',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'Cancel anytime',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom CTAs
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            notifier.activateDevTrial();
                            if (mounted) {
                              if (GoRouter.maybeOf(context) != null) {
                                context.pop();
                              } else {
                                Navigator.of(context).maybePop();
                              }
                            }
                          },
                          icon: const Icon(Icons.star_rounded, size: 20),
                          label: Text(_isAnnualSelected
                              ? 'Start Free Trial (\$89/yr)'
                              : 'Start Free Trial (\$9/mo)'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final restored = await notifier.restorePurchases();
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(restored
                                    ? 'Purchases restored successfully!'
                                    : 'No active purchases found.'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Restore Purchases',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
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
