import 'package:flutter/material.dart';

import '../data/seed_entries.dart';
import '../models/timeline_entry.dart';
import '../utils/date_format.dart';
import '../widgets/board/day_board.dart';
import '../widgets/entry_form_sheet.dart';
import '../widgets/glass/edge_swipe_stack.dart';

/// The app's only screen: a sheet of paper for the day, a calendar along
/// the bottom, and to-do piles that slide in as coloured glass from the edges.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TimelineEntry> _entries = buildSeedEntries();
  late DateTime _day = dateOnly(DateTime.now());

  void _addEntry(TimelineEntry entry) {
    setState(() => _entries.add(entry));
  }

  void _toggleDone(TimelineEntry entry) {
    setState(() {
      if (entry is TaskEntry) entry.done = !entry.done;
      if (entry is GoalEntry) entry.done = !entry.done;
    });
  }

  void _removeEntry(TimelineEntry entry) {
    setState(() => _entries.remove(entry));
  }

  void _onEntryEdited() {
    setState(() {});
  }

  void _selectDay(DateTime day) {
    setState(() => _day = dateOnly(day));
  }

  /// Tasks, events, and goals for [owner] on the selected day — they only
  /// appear once a glass sheet is pulled in over the paper.
  List<TimelineEntry> _todosFor(EntryOwner owner) {
    final todos = _entries.where((entry) {
      if (entry.owner != owner) return false;
      if (entry is GoalEntry || entry.startDate == null) return true;
      return entry.occursOn(_day);
    }).toList();
    todos.sort((a, b) {
      final aDate = a.startDate;
      final bDate = b.startDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
    return todos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EdgeSwipeStack(
        mineTodos: _todosFor(EntryOwner.me),
        partnerTodos: _todosFor(EntryOwner.partner),
        groupTodos: _todosFor(EntryOwner.shared),
        onToggle: _toggleDone,
        onDelete: _removeEntry,
        onEdited: _onEntryEdited,
        onAddTodo: (owner) => showEntryFormSheet(
          context,
          onCreate: _addEntry,
          defaultKind: EntryKind.task,
          defaultOwner: owner,
        ),
        child: SafeArea(
          child: DayBoard(
            day: _day,
            entries: _entries,
            onSelectDay: _selectDay,
            onCreate: _addEntry,
          ),
        ),
      ),
    );
  }
}
