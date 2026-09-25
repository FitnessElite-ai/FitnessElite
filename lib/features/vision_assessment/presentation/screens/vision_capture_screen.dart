import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../../../../shared/animations/glass_entrance_animation.dart';
import '../../../../shared/animations/slide_in_animation.dart';
import '../../../../shared/widgets/fitness_elite_logo.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/vision_photo.dart';
import '../../providers/vision_assessment_provider.dart';
import '../widgets/photo_capture_card.dart';

/// Photo Capture Screen for Vision AI Assessment.
class VisionCaptureScreen extends ConsumerWidget {
  const VisionCaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final state = ref.watch(visionAssessmentNotifierProvider);
    final notifier = ref.read(visionAssessmentNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/vision-intro'),
        ),
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
        actions: [
          TextButton(
            onPressed: () {
              notifier.skipAssessment();
              context.go('/plan-preview');
            },
            child: Text(
              l10n.skipForNow,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ),
          const SizedBox(width: 8),
        ],
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
                      // Header Title
                      SlideInAnimation(
                        direction: SlideDirection.up,
                        child: Text(
                          l10n.photoGuidanceTitle,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      FadeInAnimation(
                        delay: const Duration(milliseconds: 150),
                        child: Text(
                          l10n.photoGuidanceSub,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Photo Guidance Tips
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 180),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _GuidanceItem(text: l10n.guidanceFullBody),
                              _GuidanceItem(text: l10n.guidanceLighting),
                              _GuidanceItem(text: l10n.guidancePosition),
                              _GuidanceItem(text: l10n.guidanceBackground),
                              _GuidanceItem(text: l10n.guidanceCameraHeight),
                              _GuidanceItem(text: l10n.guidanceClothing),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Privacy Banner
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 220),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.electricBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.privacyNotice,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 1. Front Photo (Recommended)
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 250),
                        child: PhotoCaptureCard(
                          title: l10n.frontPhotoTitle,
                          subtitle: l10n.frontPhotoSub,
                          type: PhotoType.front,
                          photo: state.frontPhoto,
                          onPhotoCaptured: notifier.setFrontPhoto,
                          onPhotoRemoved: () =>
                              notifier.removePhoto(PhotoType.front),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. Side Photo (Optional)
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 350),
                        child: PhotoCaptureCard(
                          title: l10n.sidePhotoTitle,
                          subtitle: l10n.sidePhotoSub,
                          type: PhotoType.side,
                          photo: state.sidePhoto,
                          onPhotoCaptured: notifier.setSidePhoto,
                          onPhotoRemoved: () =>
                              notifier.removePhoto(PhotoType.side),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. Back Photo (Optional)
                      GlassEntranceAnimation(
                        delay: const Duration(milliseconds: 450),
                        child: PhotoCaptureCard(
                          title: l10n.backPhotoTitle,
                          subtitle: l10n.backPhotoSub,
                          type: PhotoType.back,
                          photo: state.backPhoto,
                          onPhotoCaptured: notifier.setBackPhoto,
                          onPhotoRemoved: () =>
                              notifier.removePhoto(PhotoType.back),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  delay: const Duration(milliseconds: 550),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: state.hasRequiredFrontPhoto
                          ? () => context.go('/vision-analysis')
                          : null,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: Text(l10n.analyzePhotos),
                    ),
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

class _GuidanceItem extends StatelessWidget {
  final String text;

  const _GuidanceItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: AppColors.electricBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
