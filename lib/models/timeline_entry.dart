import 'package:flutter/material.dart';

import '../design.dart';
import '../utils/date_format.dart';

/// Which kind of entry the add-entry popup is currently building.
enum EntryKind { task, event, goal }

enum Importance { low, medium, high }

extension ImportanceLabel on Importance {
  String get label => switch (this) {
    Importance.low => 'Low',
    Importance.medium => 'Medium',
    Importance.high => 'High',
  };
}

/// Whose entry this is. Shell for multi-user mode: there's no backend yet,
/// so this device is always the "me" account (see seed_entries.dart for
/// which user that is) and "partner" only ever appears on seeded/demo
/// data — you can create entries as yourself or as [shared], never as
/// [partner], mirroring "you can only add a thing for yourself or shared".
enum EntryOwner { me, partner, shared }

extension EntryOwnerStyle on EntryOwner {
  /// The color used everywhere this entry shows up — list, calendar, etc.
  /// Defined in [AppDesign] so the whole palette lives in one file.
  Color get color => switch (this) {
    EntryOwner.me => AppDesign.meColor,
    EntryOwner.partner => AppDesign.partnerColor,
    EntryOwner.shared => AppDesign.sharedColor,
  };

  String get label => switch (this) {
    EntryOwner.me => 'Me',
    EntryOwner.partner => 'Partner',
    EntryOwner.shared => 'Shared',
  };
}

/// Mixed into entries that can be ticked off as finished (tasks, goals).
mixin Completable {
  bool done = false;
}

/// Base type for anything that can show up on the home timeline.
///
/// Add a new kind (e.g. a "note") by extending this class and creating a
/// matching tile widget in widgets/timeline/.
abstract class TimelineEntry {
  TimelineEntry({
    required this.title,
    this.startDate,
    this.endDate,
    this.importance = Importance.medium,
    this.description = '',
    this.people = const [],
    this.owner = EntryOwner.me,
  });

  // Mutable so the entry can be edited in place from the detail popup
  // without needing to rebuild/replace it in the entries list.
  String title;
  DateTime? startDate;
  DateTime? endDate;
  Importance importance;
  String description;
  List<String> people;
  EntryOwner owner;

  String get formattedRange {
    final start = startDate;
    if (start == null) return 'No date';
    if (endDate == null) return formatDateTime(start);
    final endText = isSameDay(start, endDate!)
        ? formatTime(endDate!)
        : formatDateTime(endDate!);
    return '${formatDateTime(start)} – $endText';
  }

  /// Whether this entry is active on [day] (i.e. [day] falls anywhere in
  /// its start-to-end span). Used to color the calendar and filter the
  /// list view down to a single day. Entries with no date never occur on
  /// any day.
  bool occursOn(DateTime day) {
    final start = startDate;
    if (start == null) return false;
    final target = dateOnly(day);
    final startDay = dateOnly(start);
    final end = dateOnly(endDate ?? start);
    return !target.isBefore(startDay) && !target.isAfter(end);
  }
}

class TaskEntry extends TimelineEntry with Completable {
  TaskEntry({
    required super.title,
    super.startDate,
    super.endDate,
    super.importance,
    super.description,
    super.people,
    super.owner,
    bool done = false,
  }) {
    this.done = done;
  }
}

class EventEntry extends TimelineEntry {
  EventEntry({
    required super.title,
    super.startDate,
    super.endDate,
    super.importance,
    super.description,
    super.people,
    super.owner,
  });
}

/// A goal: never has a date, always pinned above the rest of the list,
/// and can be ticked off like a task.
class GoalEntry extends TimelineEntry with Completable {
  GoalEntry({
    required super.title,
    super.importance,
    super.description,
    super.people,
    super.owner,
    bool done = false,
  }) {
    this.done = done;
  }
}
