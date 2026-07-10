import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../constants/mode_styles.dart';
import '../controllers/planned_session_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/app_mode.dart';
import '../models/planned_session.dart';
import '../models/skill.dart';
import '../utils/date_utils.dart';

class PlanAheadScreen extends StatefulWidget {
  const PlanAheadScreen({
    super.key,
    this.initialDate,
    this.session,
  });

  final DateTime? initialDate;
  final PlannedSession? session;

  @override
  State<PlanAheadScreen> createState() => _PlanAheadScreenState();
}

class _PlanAheadScreenState extends State<PlanAheadScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  String? _selectedSkillId;
  late DateTime _selectedDate;
  late String _startTime;
  late String _endTime;
  bool _isSaving = false;

  bool get _isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();
    final session = widget.session;
    _selectedSkillId = session?.skillId;
    _selectedDate = ProofDateUtils.dateOnly(
      session?.date ?? widget.initialDate ?? DateTime.now(),
    );
    _startTime = session?.plannedStartTime ?? '09:00';
    _endTime = session?.plannedEndTime ?? '10:00';
    _titleController = TextEditingController(text: session?.title ?? '');
    _noteController = TextEditingController(text: session?.note ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final mode =
        widget.session?.mode ?? context.read<SettingsController>().appMode;
    final plannedMinutes = ProofDateUtils.minutesBetween(_startTime, _endTime);
    if (plannedMinutes <= 0) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final status = widget.session?.completedProofId == null
        ? PlannedSessionStatus.planned
        : widget.session!.status;
    final session = PlannedSession(
      id: widget.session?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      skillId: _selectedSkillId!,
      title: title,
      note: _noteController.text.trim(),
      date: _selectedDate,
      plannedStartTime: _startTime,
      plannedEndTime: _endTime,
      plannedMinutes: plannedMinutes,
      mode: mode,
      status: status,
      createdAt: widget.session?.createdAt ?? DateTime.now(),
      completedProofId: widget.session?.completedProofId,
    );

    final controller = context.read<PlannedSessionController>();
    if (_isEditing) {
      await controller.updateSession(session);
    } else {
      await controller.addSession(session);
    }

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Plan updated' : 'Plan saved')),
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
    final initialValue = _timeOfDayFromString(isStart ? _startTime : _endTime);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<SettingsController>().appMode;
    final plannedMinutes = ProofDateUtils.minutesBetween(_startTime, _endTime);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Plan' : 'Plan Ahead')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _PlanHeader(mode: widget.session?.mode ?? mode),
            const SizedBox(height: 18),
            _FormShell(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
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
                            setState(() {
                              _selectedSkillId = skillId;
                              if (_titleController.text.trim().isEmpty &&
                                  skillId != null) {
                                final skill =
                                    skillController.skillById(skillId);
                                _titleController.text = '${skill.name} session';
                              }
                            });
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
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Plan title',
                        hintText: 'Coding session',
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
                    _DateTimePickerRow(
                      selectedDate: _selectedDate,
                      startTime: _startTime,
                      endTime: _endTime,
                      onPickDate: _pickDate,
                      onPickStart: () => _pickTime(isStart: true),
                      onPickEnd: () => _pickTime(isStart: false),
                    ),
                    const SizedBox(height: 10),
                    _PlannedMinutesPill(minutes: plannedMinutes),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _noteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Optional note',
                        hintText: 'What should this session accomplish?',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _savePlan,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.event_available_outlined),
                      label: Text(_isSaving ? 'Saving...' : 'Save Plan'),
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

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.mode});

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
            child: Icon(mode.icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan ahead',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Schedule a skill block, then earn bonus SP when you follow through.',
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
  final String startTime;
  final String endTime;
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
                label: Text(ProofDateUtils.formatTimeLabel(startTime)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickEnd,
                icon: const Icon(Icons.flag_outlined),
                label: Text(ProofDateUtils.formatTimeLabel(endTime)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlannedMinutesPill extends StatelessWidget {
  const _PlannedMinutesPill({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final isValid = minutes > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.timer_outlined : Icons.warning_amber_outlined,
            color: isValid ? colorScheme.primary : colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isValid
                  ? '$minutes planned minutes'
                  : 'End time must be after start time',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isValid
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.error,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
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
