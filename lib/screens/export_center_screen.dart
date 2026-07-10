import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/mode_styles.dart';
import '../controllers/proof_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/app_mode.dart';
import '../models/export_format.dart';
import '../models/proof.dart';
import '../models/skill.dart';
import '../utils/export_utils.dart';
import '../utils/stats_utils.dart';

class ExportCenterScreen extends StatefulWidget {
  const ExportCenterScreen({super.key});

  @override
  State<ExportCenterScreen> createState() => _ExportCenterScreenState();
}

class _ExportCenterScreenState extends State<ExportCenterScreen> {
  ExportFormat _selectedFormat = ExportFormat.linkedInPost;

  Future<void> _copyExport(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export text copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Center')),
      body: SafeArea(
        child: Consumer3<ProofController, SkillController, SettingsController>(
          builder:
              (context, proofController, skillController, settings, child) {
            final proofs = proofController.proofs;
            final skills = skillController.skills;
            final mode = settings.appMode;
            final exportText = ExportUtils.generate(
              format: _selectedFormat,
              proofs: proofs,
              skills: skills,
              mode: mode,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _ExportHeader(mode: mode),
                const SizedBox(height: 18),
                _ExportSnapshot(
                  proofs: proofs,
                  skills: skills,
                  mode: mode,
                ),
                const SizedBox(height: 18),
                _FormatPicker(
                  selectedFormat: _selectedFormat,
                  onSelected: (format) {
                    setState(() => _selectedFormat = format);
                  },
                ),
                const SizedBox(height: 18),
                _PreviewCard(
                  format: _selectedFormat,
                  text: exportText,
                  onCopy: () => _copyExport(context, exportText),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExportHeader extends StatelessWidget {
  const _ExportHeader({required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: modeGradientColors(mode),
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: modeAccentColor(mode).withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Icon(Icons.ios_share, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Center',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Turn your proof stack into resume, social, and portfolio copy.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportSnapshot extends StatelessWidget {
  const _ExportSnapshot({
    required this.proofs,
    required this.skills,
    required this.mode,
  });

  final List<Proof> proofs;
  final List<Skill> skills;
  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    final weeklyProofs = StatsUtils.proofsFromLastSevenDays(proofs);
    final totalMinutes = StatsUtils.totalMinutes(proofs);
    final weeklyMinutes = StatsUtils.totalMinutes(weeklyProofs);
    final strongestSkill = StatsUtils.bestSkillName(proofs, skills);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _SnapshotTile(
          label: 'Total proofs',
          value: '${proofs.length}',
          icon: Icons.task_alt,
        ),
        _SnapshotTile(
          label: 'Total minutes',
          value: '$totalMinutes',
          icon: Icons.timer_outlined,
        ),
        _SnapshotTile(
          label: 'This week',
          value: '${weeklyProofs.length} / $weeklyMinutes min',
          icon: Icons.date_range,
        ),
        _SnapshotTile(
          label: 'Strongest',
          value: strongestSkill,
          icon: Icons.emoji_events_outlined,
          color: modeAccentColor(mode),
        ),
      ],
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 20),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _FormatPicker extends StatelessWidget {
  const _FormatPicker({
    required this.selectedFormat,
    required this.onSelected,
  });

  final ExportFormat selectedFormat;
  final ValueChanged<ExportFormat> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose export type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            selectedFormat.helperText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExportFormat.values.map((format) {
              return ChoiceChip(
                avatar: Icon(format.icon, size: 18),
                label: Text(format.displayName),
                selected: selectedFormat == format,
                onSelected: (_) => onSelected(format),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.format,
    required this.text,
    required this.onCopy,
  });

  final ExportFormat format;
  final String text;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border:
            Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.07,
            ),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(format.icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  format.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: SelectableText(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy),
            label: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }
}
