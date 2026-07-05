import 'package:flutter/material.dart';

import '../data/seed_entries.dart';
import '../models/timeline_entry.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/calendar/calendar_view.dart';
import '../widgets/day_filter_banner.dart';
import '../widgets/owner_legend.dart';
import '../widgets/timeline/timeline_list.dart';
import '../widgets/view_mode.dart';
import '../widgets/whose_filter_button.dart';

/// The app's only screen. Shows either the chronological list or the
/// month calendar, switchable via the toggle in [BottomActionBar], with a
/// Both/Mine/Theirs filter for the multi-user shell (see seed_entries.dart
/// — this showcase runs as the "me"/pink account).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TimelineEntry> _entries = buildSeedEntries();
  ViewMode _viewMode = ViewMode.list;
  WhoseFilter _whoseFilter = WhoseFilter.both;
  DateTime? _filterDay;

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

  void _changeViewMode(ViewMode mode) {
    setState(() {
      _viewMode = mode;
      if (mode == ViewMode.calendar) _filterDay = null;
    });
  }

  void _changeWhoseFilter(WhoseFilter filter) {
    setState(() => _whoseFilter = filter);
  }

  void _selectDay(DateTime day) {
    setState(() {
      _filterDay = day;
      _viewMode = ViewMode.list;
    });
  }

  void _clearDayFilter() {
    setState(() => _filterDay = null);
  }

  void _onEntryEdited() {
    setState(() {});
  }

  /// Entries visible under the current Both/Mine/Theirs filter, regardless
  /// of list vs. calendar view.
  List<TimelineEntry> get _filteredEntries =>
      _entries.where((entry) => _whoseFilter.matches(entry.owner)).toList();

  /// Dated entries first, chronologically; undated entries (no time frame
  /// set, including goals) trail at the end — TimelineList pins goals back
  /// above everything regardless of their position here. Day-filtering
  /// only makes sense for dated entries, so it naturally drops the rest.
  List<TimelineEntry> get _visibleEntries {
    final filtered = _filteredEntries;
    final dated = filtered.where((entry) => entry.startDate != null).toList()
      ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
    final undated = filtered.where((entry) => entry.startDate == null).toList();

    if (_filterDay != null) {
      return dated.where((entry) => entry.occursOn(_filterDay!)).toList();
    }
    return [...dated, ...undated];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 8),
            child: OwnerLegend(),
          ),
          Expanded(
            child: _viewMode == ViewMode.list
                ? Column(
                    children: [
                      if (_filterDay != null)
                        DayFilterBanner(date: _filterDay!, onClear: _clearDayFilter),
                      Expanded(
                        child: TimelineList(
                          entries: _visibleEntries,
                          onToggleDone: _toggleDone,
                          onDelete: _removeEntry,
                          onEdited: _onEntryEdited,
                          emptyMessage: _filterDay == null
                              ? 'Nothing here yet. Add a task or event below!'
                              : 'Nothing scheduled for this day.',
                        ),
                      ),
                    ],
                  )
                : CalendarView(entries: _filteredEntries, onDaySelected: _selectDay),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        mode: _viewMode,
        onToggleMode: () => _changeViewMode(
          _viewMode == ViewMode.list ? ViewMode.calendar : ViewMode.list,
        ),
        whoseFilter: _whoseFilter,
        onWhoseFilterChanged: _changeWhoseFilter,
        onCreate: _addEntry,
      ),
    );
  }
}
