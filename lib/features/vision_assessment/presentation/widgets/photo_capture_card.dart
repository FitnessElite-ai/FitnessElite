import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../models/vision_photo.dart';

/// Reusable Photo Capture & Preview Card supporting Camera, Gallery, Preview, Retake, and Remove actions.
class PhotoCaptureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final PhotoType type;
  final VisionPhoto? photo;
  final ValueChanged<String> onPhotoCaptured;
  final VoidCallback onPhotoRemoved;

  const PhotoCaptureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
    this.photo,
    required this.onPhotoCaptured,
    required this.onPhotoRemoved,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null && image.path.isNotEmpty) {
        onPhotoCaptured(image.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera/Gallery selection unavailable: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = photo != null && photo!.filePath.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (hasPhoto)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  onPressed: onPhotoRemoved,
                  tooltip: l10n.removePhoto,
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (hasPhoto) ...[
            // Photo Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  File(photo!.filePath).existsSync()
                      ? Image.file(
                          File(photo!.filePath),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 140,
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          child: const Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.electricBlue,
                              size: 40,
                            ),
                          ),
                        ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_rounded,
                            color: AppColors.electricBlue, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Captured',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(context, ImageSource.camera),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retakePhoto),
              ),
            ),
          ] else ...[
            // Camera & Gallery Pickers
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(context, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: Text(l10n.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(context, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: Text(l10n.gallery),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
