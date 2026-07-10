import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../controllers/planned_session_controller.dart';
import '../controllers/proof_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/proof.dart';
import '../models/skill.dart';
import '../utils/date_utils.dart';
import '../utils/skill_points_utils.dart';

class EditProofScreen extends StatefulWidget {
  const EditProofScreen({super.key, required this.proof});

  final Proof proof;

  @override
  State<EditProofScreen> createState() => _EditProofScreenState();
}

class _EditProofScreenState extends State<EditProofScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _minutesController;
  late final TextEditingController _noteController;

  late String _selectedSkillId;
  late DateTime _selectedDate;
  String? _startTime;
  String? _endTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.proof.title);
    _minutesController = TextEditingController(
      text: widget.proof.minutes.toString(),
    );
    _noteController = TextEditingController(text: widget.proof.note);
    _selectedSkillId = widget.proof.skillId;
    _selectedDate = widget.proof.date;
    _startTime = widget.proof.startTime;
    _endTime = widget.proof.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final proofController = context.read<ProofController>();
    final plannedController = context.read<PlannedSessionController>();
    final plannedSession =
        plannedController.sessionById(widget.proof.plannedSessionId);
    final minutes = int.parse(_minutesController.text.trim());
    final updatedProof = widget.proof.copyWith(
      title: _titleController.text.trim(),
      skillId: _selectedSkillId,
      minutes: minutes,
      note: _noteController.text.trim(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      baseSp: SkillPointsUtils.baseSpForMinutes(minutes),
      bonusSp: SkillPointsUtils.bonusForProof(
        completedMinutes: minutes,
        plannedSession: plannedSession,
      ),
    );

    await proofController.updateProof(updatedProof);
    await plannedController.markFromProof(updatedProof);

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Proof updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Proof'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const _EditFormHeader(),
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
                            if (skillId != null) {
                              setState(() => _selectedSkillId = skillId);
                            }
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
                    _DateTimePickerRow(
                      selectedDate: _selectedDate,
                      startTime: _startTime,
                      endTime: _endTime,
                      onPickDate: _pickDate,
                      onPickStart: () => _pickTime(isStart: true),
                      onPickEnd: () => _pickTime(isStart: false),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Minutes spent',
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                      validator: (value) {
                        final hasOnlyOneTime =
                            (_startTime == null) != (_endTime == null);
                        if (hasOnlyOneTime) {
                          return 'Choose both start and end time, or neither';
                        }

                        if (_startTime != null &&
                            ProofDateUtils.minutesBetween(
                                  _startTime,
                                  _endTime,
                                ) <=
                                0) {
                          return 'End time must be after start time';
                        }

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
                      onPressed: _isSaving ? null : _saveChanges,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = ProofDateUtils.dateOnly(picked));
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialValue = _timeOfDayFromString(
      isStart ? _startTime : _endTime,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialValue ?? TimeOfDay.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _startTime = _formatTimeOfDay(picked);
      } else {
        _endTime = _formatTimeOfDay(picked);
      }

      final minutes = ProofDateUtils.minutesBetween(_startTime, _endTime);
      if (minutes > 0) {
        _minutesController.text = minutes.toString();
      }
    });
  }

  String _formatTimeOfDay(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay? _timeOfDayFromString(String? value) {
    final minutes = ProofDateUtils.minutesFromTimeString(value);
    if (minutes == null) {
      return null;
    }
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}

class _DateTimePickerRow extends StatelessWidget {
  const _DateTimePickerRow({
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.onPickDate,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final DateTime selectedDate;
  final String? startTime;
  final String? endTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: onPickDate,
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(ProofDateUtils.friendlyDate(selectedDate)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickStart,
                icon: const Icon(Icons.play_arrow_outlined),
                label: Text(
                  startTime == null
                      ? 'Start time'
                      : ProofDateUtils.formatTimeLabel(startTime),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickEnd,
                icon: const Icon(Icons.flag_outlined),
                label: Text(
                  endTime == null
                      ? 'End time'
                      : ProofDateUtils.formatTimeLabel(endTime),
                ),
              ),
            ),
          ],
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

class _EditFormHeader extends StatelessWidget {
  const _EditFormHeader();

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
            child: const Icon(Icons.edit_note, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refine this proof',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Clean up the details while keeping the original timeline date.',
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
