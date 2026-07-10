import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'controllers/proof_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/skill_controller.dart';
import 'models/app_mode.dart';
import 'screens/add_proof_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/timeline_screen.dart';
import 'services/proof_storage_service.dart';
import 'services/settings_storage_service.dart';
import 'services/skill_storage_service.dart';
import 'widgets/mode_activation_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final proofController = ProofController(ProofStorageService());
  await proofController.loadProofs();

  final settingsController = SettingsController(SettingsStorageService());
  await settingsController.loadSettings();

  final skillController = SkillController(SkillStorageService());
  await skillController.loadSkills();

  runApp(
    ProofBoardApp(
      proofController: proofController,
      settingsController: settingsController,
      skillController: skillController,
    ),
  );
}

class ProofBoardApp extends StatelessWidget {
  const ProofBoardApp({
    super.key,
    required this.proofController,
    required this.settingsController,
    required this.skillController,
  });

  final ProofController proofController;
  final SettingsController settingsController;
  final SkillController skillController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: proofController),
        ChangeNotifierProvider.value(value: settingsController),
        ChangeNotifierProvider.value(value: skillController),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'ProofBoard',
            debugShowCheckedModeBanner: false,
            theme: buildLightAppTheme(settings.appMode),
            darkTheme: buildDarkAppTheme(settings.appMode),
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
  AppMode? _lastSeenMode;
  AppMode? _activationMode;
  int _activationId = 0;

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

  void _showModeActivation(AppMode mode) {
    final nextActivationId = _activationId + 1;
    setState(() {
      _activationMode = mode;
      _activationId = nextActivationId;
    });

    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted || _activationId != nextActivationId) {
        return;
      }

      setState(() => _activationMode = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appMode = context.watch<SettingsController>().appMode;

    if (_lastSeenMode == null) {
      _lastSeenMode = appMode;
    } else if (_lastSeenMode != appMode) {
      _lastSeenMode = appMode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showModeActivation(appMode);
        }
      });
    }

    final pages = [
      HomeScreen(
        onAddProof: _openAddProof,
        onOpenSettings: _openSettings,
      ),
      const TimelineScreen(),
      AddProofScreen(onSaved: _returnHome),
      const StatsScreen(),
      const CalendarScreen(),
    ];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _activationMode == null
                        ? const SizedBox.shrink()
                        : ModeActivationOverlay(
                            key: ValueKey(_activationId),
                            mode: _activationMode!,
                          ),
                  ),
                ),
              ),
            ],
          ),
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
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
          ],
        ),
      ),
    );
  }
}
