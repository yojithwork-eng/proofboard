import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'controllers/proof_controller.dart';
import 'controllers/settings_controller.dart';
import 'screens/add_proof_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/timeline_screen.dart';
import 'services/proof_storage_service.dart';
import 'services/settings_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final proofController = ProofController(ProofStorageService());
  await proofController.loadProofs();

  final settingsController = SettingsController(SettingsStorageService());
  await settingsController.loadSettings();

  runApp(
    ProofBoardApp(
      proofController: proofController,
      settingsController: settingsController,
    ),
  );
}

class ProofBoardApp extends StatelessWidget {
  const ProofBoardApp({
    super.key,
    required this.proofController,
    required this.settingsController,
  });

  final ProofController proofController;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: proofController),
        ChangeNotifierProvider.value(value: settingsController),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'ProofBoard',
            debugShowCheckedModeBanner: false,
            theme: buildLightAppTheme(),
            darkTheme: buildDarkAppTheme(),
            themeMode: settings.themeMode,
            home: const ProofBoardShell(),
          );
        },
      ),
    );
  }
}

class ProofBoardShell extends StatefulWidget {
  const ProofBoardShell({super.key});

  @override
  State<ProofBoardShell> createState() => _ProofBoardShellState();
}

class _ProofBoardShellState extends State<ProofBoardShell> {
  int _selectedIndex = 0;

  void _openAddProof() {
    setState(() => _selectedIndex = 2);
  }

  void _returnHome() {
    setState(() => _selectedIndex = 0);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onAddProof: _openAddProof,
        onOpenSettings: _openSettings,
      ),
      const TimelineScreen(),
      AddProofScreen(onSaved: _returnHome),
      const StatsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.32
                    : 0.08,
              ),
              blurRadius: 24,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.view_timeline_outlined),
              selectedIcon: Icon(Icons.view_timeline),
              label: 'Timeline',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
