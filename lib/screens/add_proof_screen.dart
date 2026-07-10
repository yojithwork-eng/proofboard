import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../controllers/proof_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/proof.dart';
import '../models/skill.dart';

class AddProofScreen extends StatefulWidget {
  const AddProofScreen({super.key, required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<AddProofScreen> createState() => _AddProofScreenState();
}

class _AddProofScreenState extends State<AddProofScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedSkillId;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveProof() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final proof = Proof(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      skillId: _selectedSkillId!,
      minutes: int.parse(_minutesController.text.trim()),
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    await context.read<ProofController>().addProof(proof);

    if (!mounted) {
      return;
    }

    _titleController.clear();
    _minutesController.clear();
    _noteController.clear();
    setState(() {
      _selectedSkillId = null;
      _isSaving = false;
    });

    FocusScope.of(context).unfocus();
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proof saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const _FormHeader(
          title: 'Log today\'s proof',
          subtitle: 'Turn one focused work session into portfolio momentum.',
          icon: Icons.add_task,
        ),
        const SizedBox(height: 18),
        _FormShell(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Built a login screen',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Consumer<SkillController>(
                  builder: (context, skillController, child) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedSkillId,
                      decoration: const InputDecoration(
                        labelText: 'Skill',
                        prefixIcon: Icon(Icons.auto_awesome),
                      ),
                      items: skillController.skills
                          .map(
                            (skill) => DropdownMenuItem(
                              value: skill.id,
                              child: _SkillOption(skill: skill),
                            ),
                          )
                          .toList(),
                      onChanged: (skillId) {
                        setState(() => _selectedSkillId = skillId);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Skill is required';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Minutes spent',
                    hintText: '45',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  validator: (value) {
                    final minutes = int.tryParse(value?.trim() ?? '');
                    if (minutes == null || minutes <= 0) {
                      return 'Minutes must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _noteController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Short note',
                    hintText: 'What did you do, learn, or finish?',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveProof,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bolt_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Add to Proof Stack'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillOption extends StatelessWidget {
  const _SkillOption({required this.skill});

  final Skill skill;

  @override
  Widget build(BuildContext context) {
    final color = skillColor(skill);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(skillIcon(skill), color: color, size: 18),
        const SizedBox(width: 8),
        Text(skill.name),
      ],
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07152F), Color(0xFF2457FF)],
        ),
        borderRadius: BorderRadius.circular(28),
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
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.20 : 0.08,
            ),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
