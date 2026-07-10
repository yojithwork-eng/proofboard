import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/mode_styles.dart';
import '../controllers/planned_session_controller.dart';
import '../controllers/proof_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/app_mode.dart';
import '../widgets/mode_activation_overlay.dart';
import 'export_center_screen.dart';
import 'manage_skills_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppMode? _activationMode;
  int _activationId = 0;

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account sync is coming soon.')),
    );
  }

  Future<void> _changeMode(BuildContext context, AppMode mode) async {
    final settings = context.read<SettingsController>();
    if (settings.appMode == mode) {
      return;
    }

    await settings.setAppMode(mode);
    if (!mounted) {
      return;
    }

    _showModeActivation(mode);
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

  Future<void> _confirmClearData(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all proof data?'),
          content: const Text(
            'This removes every saved proof and planned session from this device. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear Data'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true && context.mounted) {
      await context.read<ProofController>().clearProofs();
      if (context.mounted) {
        await context.read<PlannedSessionController>().clearSessions();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All proof and schedule data cleared')),
        );
      }
    }
  }

  void _openExportCenter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ExportCenterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appMode = context.watch<SettingsController>().appMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: modeGradientColors(appMode),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ProofBoard setup',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Tune the app, manage local data, and run ${appMode.displayName} mode.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.76),
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  title: 'Account',
                  icon: Icons.account_circle_outlined,
                  child: Column(
                    children: [
                      _AccountButton(
                        label: 'Continue with Google',
                        mark: 'G',
                        onPressed: () => _showComingSoon(context),
                      ),
                      const SizedBox(height: 10),
                      _AccountButton(
                        label: 'Continue with Facebook',
                        mark: 'f',
                        onPressed: () => _showComingSoon(context),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Account sync is planned for a future version. No login packages are installed yet.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SettingsSection(
                  title: 'Appearance',
                  icon: Icons.dark_mode_outlined,
                  child: Consumer<SettingsController>(
                    builder: (context, settings, child) {
                      return SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto_outlined),
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (selection) {
                          settings.setThemeMode(selection.first);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _SettingsSection(
                  title: 'Mode',
                  icon: Icons.explore_outlined,
                  child: Consumer<SettingsController>(
                    builder: (context, settings, child) {
                      return Column(
                        children: AppMode.values
                            .map(
                              (mode) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ModeChoiceTile(
                                  mode: mode,
                                  selected: settings.appMode == mode,
                                  onTap: () => _changeMode(context, mode),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _SettingsSection(
                  title: 'Skills',
                  icon: Icons.auto_awesome,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const ManageSkillsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('Manage Skills'),
                  ),
                ),
                const SizedBox(height: 14),
                _SettingsSection(
                  title: 'Export',
                  icon: Icons.file_upload_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create copy-paste text for resumes, LinkedIn, social posts, and portfolios.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _openExportCenter(context),
                        icon: const Icon(Icons.ios_share_outlined),
                        label: const Text('Open Export Center'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Consumer2<ProofController, PlannedSessionController>(
                  builder: (context, controller, plannedController, child) {
                    final canClear = controller.totalProofs > 0 ||
                        plannedController.sessions.isNotEmpty;
                    return _SettingsSection(
                      title: 'Data',
                      icon: Icons.storage_outlined,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _DataTile(
                                  label: 'Proofs',
                                  value: '${controller.totalProofs}',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _DataTile(
                                  label: 'Plans',
                                  value: '${plannedController.sessions.length}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: canClear
                                ? () => _confirmClearData(context)
                                : null,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Clear all proof data'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                const _SettingsSection(
                  title: 'About',
                  icon: Icons.info_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ProofBoard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Turn small daily work into a visible proof-of-work portfolio.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'MVP 1.0',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
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
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.07,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ModeChoiceTile extends StatelessWidget {
  const _ModeChoiceTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = modeAccentColor(mode);
    final secondary = modeSecondaryColor(mode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.42)
                  : colorScheme.onSurface.withValues(alpha: 0.06),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accent, secondary]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(mode.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mode.focusLine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? accent : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({
    required this.label,
    required this.mark,
    required this.onPressed,
  });

  final String label;
  final String mark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                mark,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: mark == 'f' ? 19 : 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}

class _DataTile extends StatelessWidget {
  const _DataTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
          ),
        ],
      ),
    );
  }
}
