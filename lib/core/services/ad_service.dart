class ContextualAd {
  final String id;
  final String title;
  final String brandName;
  final String description;
  final String ctaText;
  final String category; // e.g. "Equipment", "Nutrition", "Apparel"

  const ContextualAd({
    required this.id,
    required this.title,
    required this.brandName,
    required this.description,
    this.ctaText = 'Learn More',
    required this.category,
  });
}

/// Privacy-first, contextual ad service for free tier users.
/// Never exposes biometrics or raw health records to advertisers.
class AdService {
  static const List<ContextualAd> _catalog = [
    ContextualAd(
      id: 'ad_1',
      title: 'Premium Non-Slip Rubber Resistance Bands',
      brandName: 'EliteGrip Athletics',
      description: 'Ideal for warm-ups, glute activation, and home dumbbell workouts.',
      category: 'Equipment',
    ),
    ContextualAd(
      id: 'ad_2',
      title: 'Clean Plant-Based Organic Protein',
      brandName: 'PureFuel Nutrition',
      description: '25g protein per scoop with zero artificial sweeteners.',
      category: 'Nutrition',
    ),
  ];

  static ContextualAd? getAdForCategory(String category, {bool isPremium = false}) {
    if (isPremium) return null; // Premium users receive an ad-free experience!
    try {
      return _catalog.firstWhere((a) => a.category.toLowerCase() == category.toLowerCase());
    } catch (_) {
      return _catalog.first;
    }
  }
}
