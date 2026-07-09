import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proofboard/controllers/proof_controller.dart';
import 'package:proofboard/controllers/settings_controller.dart';
import 'package:proofboard/main.dart';
import 'package:proofboard/models/proof.dart';
import 'package:proofboard/services/proof_storage_service.dart';
import 'package:proofboard/services/settings_storage_service.dart';

void main() {
  testWidgets('ProofBoard app renders home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final proofController = ProofController(ProofStorageService());
    final settingsController = SettingsController(SettingsStorageService());

    await tester.pumpWidget(
      ProofBoardApp(
        proofController: proofController,
        settingsController: settingsController,
      ),
    );

    expect(find.text('Build your proof stack'), findsOneWidget);
    expect(find.text('Add Proof'), findsWidgets);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
  });

  testWidgets('Timeline renders a saved proof card', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final proofController = ProofController(ProofStorageService());
    final settingsController = SettingsController(SettingsStorageService());
    await proofController.addProof(
      Proof(
        id: 'proof-1',
        title: 'Finished Flutter layout practice',
        category: ProofCategory.coding,
        minutes: 45,
        note: 'Practiced cards and navigation.',
        createdAt: DateTime(2026, 7, 9),
      ),
    );

    await tester.pumpWidget(
      ProofBoardApp(
        proofController: proofController,
        settingsController: settingsController,
      ),
    );
    await tester.tap(find.text('Timeline'));
    await tester.pumpAndSettle();

    expect(find.text('Proof timeline'), findsOneWidget);
    expect(find.text('Finished Flutter layout practice'), findsOneWidget);
    expect(find.text('Coding'), findsOneWidget);
    expect(find.text('45 min focused'), findsOneWidget);
  });

  testWidgets('Settings screen opens and shows theme options', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final proofController = ProofController(ProofStorageService());
    final settingsController = SettingsController(SettingsStorageService());

    await tester.pumpWidget(
      ProofBoardApp(
        proofController: proofController,
        settingsController: settingsController,
      ),
    );
    await tester.tap(find.byTooltip('Open settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Clear all proof data'),
      300,
    );
    expect(find.text('Clear all proof data'), findsOneWidget);
  });
}
