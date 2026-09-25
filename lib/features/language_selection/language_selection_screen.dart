import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/persistence_providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/animations/slide_in_animation.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';

class LanguageOption {
  final String code;
  final String nativeName;
  final String englishName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flag,
  });
}

const List<LanguageOption> kAppLanguages = [
  LanguageOption(code: 'en', nativeName: 'English', englishName: 'English', flag: '🇬🇧'),
  LanguageOption(code: 'es', nativeName: 'Español', englishName: 'Spanish', flag: '🇪🇸'),
  LanguageOption(code: 'zh', nativeName: '中文', englishName: 'Mandarin Chinese', flag: '🇨🇳'),
  LanguageOption(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi', flag: '🇮🇳'),
  LanguageOption(code: 'ar', nativeName: 'العربية', englishName: 'Arabic', flag: '🇦🇪'),
  LanguageOption(code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali', flag: '🇧🇩'),
  LanguageOption(code: 'te', nativeName: 'తెలుగు', englishName: 'Telugu', flag: '🇮🇳'),
  LanguageOption(code: 'mr', nativeName: 'मराठी', englishName: 'Marathi', flag: '🇮🇳'),
  LanguageOption(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil', flag: '🇮🇳'),
];

/// Premium Language Selection Screen.
/// Supports searching, native language titles, animated glass selection state,
/// instant locale/RTL switching, and SharedPreferences persistence.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    final filteredLanguages = kAppLanguages.where((lang) {
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;
      return lang.nativeName.toLowerCase().contains(query) ||
          lang.englishName.toLowerCase().contains(query) ||
          lang.code.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Title Header
              SlideInAnimation(
                direction: SlideDirection.up,
                child: Text(
                  l10n.fitnessInYourLanguage,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),

              const SizedBox(height: 8),

              FadeInAnimation(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  l10n.choosePreferredLanguage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              FadeInAnimation(
                delay: const Duration(milliseconds: 250),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: l10n.searchLanguage,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.electricBlue,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Language Cards List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = filteredLanguages[index];
                    final isSelected = currentLocale.languageCode == lang.code;

                    return GlassEntranceAnimation(
                      delay: Duration(milliseconds: 100 + (index * 40)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          borderRadius: 18,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          backgroundColor: isSelected
                              ? (isDark
                                  ? AppColors.electricBlue.withValues(alpha: 0.18)
                                  : AppColors.vividBlue.withValues(alpha: 0.12))
                              : null,
                          borderColor: isSelected
                              ? (isDark
                                  ? AppColors.electricBlue
                                  : AppColors.vividBlue)
                              : null,
                          enableGlow: isSelected,
                          onTap: () {
                            ref
                                .read(localeProvider.notifier)
                                .setLocale(lang.code);
                          },
                          child: Row(
                            children: [
                              Text(
                                lang.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.nativeName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? (isDark
                                                    ? AppColors.electricBlue
                                                    : AppColors.vividBlue)
                                                : null,
                                          ),
                                    ),
                                    Text(
                                      lang.englishName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.electricBlue
                                          : AppColors.vividBlue)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.electricBlue
                                            : AppColors.vividBlue)
                                        : (isDark
                                            ? AppColors.darkGlassBorder
                                            : AppColors.lightGlassBorder),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: isDark
                                            ? AppColors.darkBackground
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                child: GlassEntranceAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/onboarding'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.continueButton),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
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
