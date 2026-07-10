import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../controllers/planned_session_controller.dart';
import '../controllers/proof_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/proof.dart';
import '../models/skill.dart';
import '../utils/date_utils.dart';
import '../utils/skill_points_utils.dart';

class AddProofScreen extends StatefulWidget {
  const AddProofScreen({
    super.key,
    required this.onSaved,
    this.standalone = false,
    this.initialSkillId,
    this.initialTitle,
    this.initialNote,
    this.initialDate,
    this.initialStartTime,
    this.initialEndTime,
    this.initialPlannedSessionId,
  });

  final VoidCallback onSaved;
  final bool standalone;
  final String? initialSkillId;
  final String? initialTitle;
  final String? initialNote;
  final DateTime? initialDate;
  final String? initialStartTime;
  final String? initialEndTime;
  final String? initialPlannedSessionId;

  @override
  State<AddProofScreen> createState() => _AddProofScreenState();
}

class _AddProofScreenState extends State<AddProofScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _minutesController;
  late final TextEditingController _noteController;

  String? _selectedSkillId;
  late DateTime _selectedDate;
  String? _startTime;
  String? _endTime;
  String? _linkedPlannedSessionId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = ProofDateUtils.dateOnly(
      widget.initialDate ?? DateTime.now(),
    );
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
    _linkedPlannedSessionId = widget.initialPlannedSessionId;
    _selectedSkillId = widget.initialSkillId;

    final derivedMinutes = ProofDateUtils.minutesBetween(_startTime, _endTime);
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _minutesController = TextEditingController(
      text: derivedMinutes > 0 ? derivedMinutes.toString() : '',
    );
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

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

    final plannedController = context.read<PlannedSessionController>();
    final plannedSession =
        plannedController.sessionById(_linkedPlannedSessionId);
    final minutes = int.parse(_minutesController.text.trim());
    final proof = Proof(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      skillId: _selectedSkillId!,
      minutes: minutes,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      mode: plannedSession?.mode ?? context.read<SettingsController>().appMode,
      plannedSessionId: plannedSession?.id,
      baseSp: SkillPointsUtils.baseSpForMinutes(minutes),
      bonusSp: SkillPointsUtils.bonusForProof(
        completedMinutes: minutes,
        plannedSession: plannedSession,
      ),
      spRuleVersion: 1,
    );

    await context.read<ProofController>().addProof(proof);
    await plannedController.markFromProof(proof);

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Proof saved. +${proof.totalSp} SP earned')),
    );

    if (widget.standalone) {
      Navigator.of(context).pop();
      return;
    }

    _titleController.clear();
    _minutesController.clear();
    _noteController.clear();
    setState(() {
      _selectedSkillId = null;
      _selectedDate = ProofDateUtils.dateOnly(DateTime.now());
      _startTime = null;
      _endTime = null;
      _linkedPlannedSessionId = null;
      _isSaving = false;
    });

    FocusScope.of(context).unfocus();
    widget.onSaved();
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
      _updateMinutesFromTimes();
    });
  }

  void _updateMinutesFromTimes() {
    final minutes = ProofDateUtils.minutesBetween(_startTime, _endTime);
    if (minutes > 0) {
      _minutesController.text = minutes.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ListView(
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
                if (_linkedPlannedSessionId != null) ...[
                  _LinkedPlanNotice(sessionId: _linkedPlannedSessionId!),
                  const SizedBox(height: 14),
                ],
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
                    hintText: '45',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  validator: (value) {
                    final hasOnlyOneTime =
                        (_startTime == null) != (_endTime == null);
                    if (hasOnlyOneTime) {
                      return 'Choose both start and end time, or neither';
                    }

                    if (_startTime != null &&
                        ProofDateUtils.minutesBetween(_startTime, _endTime) <=
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

    if (!widget.standalone) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Log Proof')),
      body: SafeArea(child: content),
    );
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

class _LinkedPlanNotice extends StatelessWidget {
  const _LinkedPlanNotice({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final plannedSession =
        context.watch<PlannedSessionController>().sessionById(sessionId);
    if (plannedSession == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Linked to planned session: ${plannedSession.title}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
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
