import 'package:fitness_elite/app/app.dart';
import 'package:fitness_elite/core/services/local_storage_service.dart';
import 'package:fitness_elite/core/services/persistence_providers.dart';
import 'package:fitness_elite/shared/widgets/fitness_elite_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('FitnessElite App initial render smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localStorageService = LocalStorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorageService),
        ],
        child: const FitnessEliteApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1200));

    // Verify initial launch screen logo widget
    expect(find.byType(FitnessEliteLogo), findsWidgets);
  });
}
