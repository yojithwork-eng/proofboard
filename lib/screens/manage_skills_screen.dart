import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../controllers/proof_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/skill.dart';

class ManageSkillsScreen extends StatelessWidget {
  const ManageSkillsScreen({super.key});

  Future<void> _showSkillDialog(BuildContext context, {Skill? skill}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _SkillDialog(skill: skill),
    );
  }

  Future<void> _deleteSkill(BuildContext context, Skill skill) async {
    final proofController = context.read<ProofController>();
    if (proofController.isSkillUsed(skill.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${skill.name} is used by existing proofs and cannot be deleted.',
          ),
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete skill?'),
          content:
              Text('This will remove "${skill.name}" from your skill list.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<SkillController>().deleteSkill(skill.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Skills'),
      ),
      body: SafeArea(
        child: Consumer<SkillController>(
          builder: (context, skillController, child) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _Header(onAddSkill: () => _showSkillDialog(context)),
                const SizedBox(height: 18),
                ...SkillMode.values.map(
                  (mode) {
                    final modeSkills = skillController.skills
                        .where((skill) => skill.mode == mode)
                        .toList();

                    if (modeSkills.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _ModeSection(
                        mode: mode,
                        skills: modeSkills,
                        onEdit: (skill) => _showSkillDialog(
                          context,
                          skill: skill,
                        ),
                        onDelete: (skill) => _deleteSkill(context, skill),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSkillDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Skill'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAddSkill});

  final VoidCallback onAddSkill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF07152F),
            Color(0xFF123B8E),
            Color(0xFF2457FF),
          ],
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
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customize your skills',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Track what matters to your portfolio, habits, and momentum.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Add skill',
            onPressed: onAddSkill,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _ModeSection extends StatelessWidget {
  const _ModeSection({
    required this.mode,
    required this.skills,
    required this.onEdit,
    required this.onDelete,
  });

  final SkillMode mode;
  final List<Skill> skills;
  final ValueChanged<Skill> onEdit;
  final ValueChanged<Skill> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mode.displayName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        ...skills.map(
          (skill) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SkillTile(
              skill: skill,
              onEdit: () => onEdit(skill),
              onDelete: () => onDelete(skill),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({
    required this.skill,
    required this.onEdit,
    required this.onDelete,
  });

  final Skill skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = skillColor(skill);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(skillIcon(skill), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  modeLabel(skill.mode),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit skill',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete skill',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _SkillDialog extends StatefulWidget {
  const _SkillDialog({this.skill});

  final Skill? skill;

  @override
  State<_SkillDialog> createState() => _SkillDialogState();
}

class _SkillDialogState extends State<_SkillDialog> {
  late final TextEditingController _nameController;
  late int _selectedColorValue;
  late SkillMode _selectedMode;

  bool get _isEditing => widget.skill != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.skill?.name ?? '');
    _selectedColorValue =
        widget.skill?.colorValue ?? skillColorChoices.first.colorValue;
    _selectedMode = widget.skill?.mode ?? SkillMode.general;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final controller = context.read<SkillController>();
    if (_isEditing) {
      await controller.updateSkill(
        widget.skill!.copyWith(
          name: name,
          colorValue: _selectedColorValue,
          iconName: iconNameForSkillName(name),
          mode: _selectedMode,
        ),
      );
    } else {
      final id =
          '${Skill.idForName(name)}_${DateTime.now().microsecondsSinceEpoch}';
      await controller.addSkill(
        Skill(
          id: id,
          name: name,
          colorValue: _selectedColorValue,
          iconName: iconNameForSkillName(name),
          mode: _selectedMode,
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit skill' : 'Add skill'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Skill name',
                hintText: 'Sleep, Deep Work, Projects...',
                prefixIcon: Icon(Icons.auto_awesome),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mode',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<SkillMode>(
              initialValue: _selectedMode,
              items: SkillMode.values
                  .map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(mode.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (mode) {
                if (mode != null) {
                  setState(() => _selectedMode = mode);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Color',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: skillColorChoices.map((choice) {
                final selected = choice.colorValue == _selectedColorValue;
                final color = Color(choice.colorValue);

                return ChoiceChip(
                  selected: selected,
                  avatar: CircleAvatar(backgroundColor: color),
                  label: Text(choice.name),
                  onSelected: (_) {
                    setState(() => _selectedColorValue = choice.colorValue);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

String modeLabel(SkillMode mode) {
  return mode.displayName;
}
