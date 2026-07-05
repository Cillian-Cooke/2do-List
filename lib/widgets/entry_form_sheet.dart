import 'package:flutter/material.dart';

import '../design.dart';
import '../models/timeline_entry.dart';
import '../utils/date_format.dart';

/// Which kind of date the form is currently collecting.
enum DateMode { none, due, range }

IconData _kindIcon(EntryKind kind) => switch (kind) {
  EntryKind.task => Icons.check_circle_outline,
  EntryKind.event => Icons.event_outlined,
  EntryKind.goal => Icons.flag_outlined,
};

String _kindLabel(EntryKind kind) => switch (kind) {
  EntryKind.task => 'Task',
  EntryKind.event => 'Event',
  EntryKind.goal => 'Goal',
};

/// Opens the entry form as a bottom sheet.
///
/// Pass [onCreate] (and leave [initial] unset) to create a new entry —
/// tapping Save calls it with the freshly built entry.
///
/// Pass [initial] (an existing entry) to edit it in place — its fields are
/// pre-filled, its type can't be changed, and tapping Save mutates it
/// directly and calls [onSaved] so the caller can rebuild.
///
/// Tapping outside the sheet dismisses it without changing anything.
Future<void> showEntryFormSheet(
  BuildContext context, {
  TimelineEntry? initial,
  void Function(TimelineEntry entry)? onCreate,
  VoidCallback? onSaved,
}) async {
  final result = await showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EntryFormSheet(initial: initial),
  );

  if (result is TimelineEntry) {
    onCreate?.call(result);
  } else if (result == true) {
    onSaved?.call();
  }
}

class EntryFormSheet extends StatefulWidget {
  const EntryFormSheet({super.key, this.initial});

  final TimelineEntry? initial;

  @override
  State<EntryFormSheet> createState() => _EntryFormSheetState();
}

class _EntryFormSheetState extends State<EntryFormSheet> {
  late final _titleController = TextEditingController(text: widget.initial?.title);
  late final _descriptionController = TextEditingController(
    text: widget.initial?.description,
  );
  late final _peopleController = TextEditingController(
    text: widget.initial?.people.join(', '),
  );

  late EntryKind _kind = switch (widget.initial) {
    EventEntry _ => EntryKind.event,
    GoalEntry _ => EntryKind.goal,
    _ => EntryKind.task,
  };
  late Importance _importance = widget.initial?.importance ?? Importance.medium;
  // You can only ever create something as yourself or shared — "partner"
  // only appears on entries the partner already owns (seed/demo data).
  late EntryOwner _owner = widget.initial?.owner ?? EntryOwner.me;
  late DateMode _dateMode;
  late DateTime _dueDate;
  late DateTime _startDate;
  late DateTime _endDate;

  bool get _isEditing => widget.initial != null;

  // Goals never have a date, so the whole Date section stays hidden for
  // them — forced here too, in case a stale _dateMode lingers from before
  // the user switched the type to Goal.
  bool get _isGoal => _kind == EntryKind.goal;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final now = DateTime.now();

    if (initial == null) {
      // Creating new: default to a start/end range, same as before this
      // toggle existed.
      _dateMode = DateMode.range;
      _dueDate = now;
      _startDate = now;
      _endDate = now.add(const Duration(hours: 1));
    } else if (initial.startDate == null) {
      _dateMode = DateMode.none;
      _dueDate = now;
      _startDate = now;
      _endDate = now.add(const Duration(hours: 1));
    } else if (initial.endDate == null) {
      _dateMode = DateMode.due;
      _dueDate = initial.startDate!;
      _startDate = initial.startDate!;
      _endDate = initial.startDate!.add(const Duration(hours: 1));
    } else {
      _dateMode = DateMode.range;
      _dueDate = initial.startDate!;
      _startDate = initial.startDate!;
      _endDate = initial.endDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _dueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  /// Picks the whole start-to-end span in one flow: start date, then start
  /// time, then (immediately, no extra tap needed) end date, then end time.
  /// Cancelling any step leaves the previous dates untouched.
  Future<void> _pickDateRange() async {
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedStartDate == null || !mounted) return;

    final pickedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    if (pickedStartTime == null || !mounted) return;

    final newStart = DateTime(
      pickedStartDate.year,
      pickedStartDate.month,
      pickedStartDate.day,
      pickedStartTime.hour,
      pickedStartTime.minute,
    );

    final endInitial = _endDate.isBefore(newStart) ? newStart : _endDate;
    final pickedEndDate = await showDatePicker(
      context: context,
      initialDate: endInitial,
      firstDate: newStart,
      lastDate: lastDate,
    );
    if (pickedEndDate == null || !mounted) return;

    final pickedEndTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endInitial),
    );
    if (pickedEndTime == null || !mounted) return;

    final newEnd = DateTime(
      pickedEndDate.year,
      pickedEndDate.month,
      pickedEndDate.day,
      pickedEndTime.hour,
      pickedEndTime.minute,
    );

    setState(() {
      _startDate = newStart;
      _endDate = newEnd;
    });
  }

  String get _dueDateLabel => formatDateTime(_dueDate);

  String get _rangeLabel {
    final endText = isSameDay(_startDate, _endDate)
        ? formatTime(_endDate)
        : formatDateTime(_endDate);
    return '${formatDateTime(_startDate)}  →  $endText';
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final people = _peopleController.text
        .split(',')
        .map((person) => person.trim())
        .where((person) => person.isNotEmpty)
        .toList();
    final description = _descriptionController.text.trim();

    final DateTime? startDate;
    final DateTime? endDate;
    if (_isGoal) {
      startDate = null;
      endDate = null;
    } else {
      switch (_dateMode) {
        case DateMode.none:
          startDate = null;
          endDate = null;
        case DateMode.due:
          startDate = _dueDate;
          endDate = null;
        case DateMode.range:
          startDate = _startDate;
          endDate = _endDate;
      }
    }

    final existing = widget.initial;
    if (existing != null) {
      // Owner is fixed at creation time, same as type — not editable here.
      existing
        ..title = title
        ..startDate = startDate
        ..endDate = endDate
        ..importance = _importance
        ..description = description
        ..people = people;
      Navigator.pop(context, true);
      return;
    }

    final entry = switch (_kind) {
      EntryKind.task => TaskEntry(
        title: title,
        startDate: startDate,
        endDate: endDate,
        importance: _importance,
        description: description,
        people: people,
        owner: _owner,
      ),
      EntryKind.event => EventEntry(
        title: title,
        startDate: startDate,
        endDate: endDate,
        importance: _importance,
        description: description,
        people: people,
        owner: _owner,
      ),
      EntryKind.goal => GoalEntry(
        title: title,
        importance: _importance,
        description: description,
        people: people,
        owner: _owner,
      ),
    };

    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDesign.radiusSheet),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isEditing ? 'Edit entry' : 'New entry',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      // 1. Title
                      TextField(
                        controller: _titleController,
                        autofocus: !_isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. Type
                      Text('Type', style: labelStyle),
                      const SizedBox(height: 8),
                      if (_isEditing)
                        Row(
                          children: [
                            Icon(_kindIcon(_kind), size: 18),
                            const SizedBox(width: 8),
                            Text(_kindLabel(_kind)),
                          ],
                        )
                      else
                        SegmentedButton<EntryKind>(
                          segments: [
                            ButtonSegment(
                              value: EntryKind.task,
                              label: Text(_kindLabel(EntryKind.task)),
                              icon: Icon(_kindIcon(EntryKind.task)),
                            ),
                            ButtonSegment(
                              value: EntryKind.event,
                              label: Text(_kindLabel(EntryKind.event)),
                              icon: Icon(_kindIcon(EntryKind.event)),
                            ),
                            ButtonSegment(
                              value: EntryKind.goal,
                              label: Text(_kindLabel(EntryKind.goal)),
                              icon: Icon(_kindIcon(EntryKind.goal)),
                            ),
                          ],
                          selected: {_kind},
                          onSelectionChanged: (selection) {
                            setState(() => _kind = selection.first);
                          },
                        ),
                      const SizedBox(height: 20),

                      // 3. Start & end date — goals never have one.
                      if (!_isGoal) ...[
                        Text('Date', style: labelStyle),
                        const SizedBox(height: 8),
                        SegmentedButton<DateMode>(
                          segments: const [
                            ButtonSegment(
                              value: DateMode.none,
                              label: Text('No date'),
                              icon: Icon(Icons.event_busy),
                            ),
                            ButtonSegment(
                              value: DateMode.due,
                              label: Text('Due date'),
                              icon: Icon(Icons.event_outlined),
                            ),
                            ButtonSegment(
                              value: DateMode.range,
                              label: Text('Range'),
                              icon: Icon(Icons.date_range),
                            ),
                          ],
                          selected: {_dateMode},
                          onSelectionChanged: (selection) {
                            setState(() => _dateMode = selection.first);
                          },
                        ),
                        if (_dateMode == DateMode.due) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _pickDueDate,
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_dueDateLabel),
                          ),
                        ],
                        if (_dateMode == DateMode.range) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _pickDateRange,
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_rangeLabel),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],

                      // 4. Importance
                      Text('Importance', style: labelStyle),
                      const SizedBox(height: 8),
                      SegmentedButton<Importance>(
                        segments: const [
                          ButtonSegment(value: Importance.low, label: Text('Low')),
                          ButtonSegment(value: Importance.medium, label: Text('Medium')),
                          ButtonSegment(value: Importance.high, label: Text('High')),
                        ],
                        selected: {_importance},
                        onSelectionChanged: (selection) {
                          setState(() => _importance = selection.first);
                        },
                      ),
                      const SizedBox(height: 20),

                      // 5. Description
                      TextField(
                        controller: _descriptionController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 6. People
                      TextField(
                        controller: _peopleController,
                        decoration: const InputDecoration(
                          labelText: 'People',
                          hintText: 'Comma-separated names',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Who this belongs to — you can only add for
                      // yourself or shared, never on your partner's
                      // behalf, so "Partner" never appears as a choice.
                      Text("Who's this for?", style: labelStyle),
                      const SizedBox(height: 8),
                      if (_isEditing)
                        Row(
                          children: [
                            Icon(Icons.circle, size: 14, color: _owner.color),
                            const SizedBox(width: 8),
                            Text(_owner.label),
                          ],
                        )
                      else
                        SegmentedButton<EntryOwner>(
                          segments: [
                            ButtonSegment(
                              value: EntryOwner.me,
                              label: Text(EntryOwner.me.label),
                              icon: Icon(Icons.circle, size: 14, color: EntryOwner.me.color),
                            ),
                            ButtonSegment(
                              value: EntryOwner.shared,
                              label: Text(EntryOwner.shared.label),
                              icon: Icon(Icons.circle, size: 14, color: EntryOwner.shared.color),
                            ),
                          ],
                          selected: {_owner},
                          onSelectionChanged: (selection) {
                            setState(() => _owner = selection.first);
                          },
                        ),
                      const SizedBox(height: 28),

                      FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(_isEditing ? 'Save changes' : 'Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
