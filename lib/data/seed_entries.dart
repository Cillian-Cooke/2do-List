import '../models/timeline_entry.dart';

/// Demo data for the multi-user shell: this showcase runs as the "me"
/// (blue glass) account — a girlfriend whose partner (red glass) is a
/// second local, not-yet-networked account. Group/shared things are green.
/// Nothing here is persisted; it's just enough of a mix of owners, types
/// and dates to show the day board, the stacked glass sheets, and the
/// calendar heatmap.
List<TimelineEntry> buildSeedEntries() {
  DateTime at(int offsetDays, [int hour = 9, int minute = 0]) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, hour, minute);
    return base.add(Duration(days: offsetDays));
  }

  return [
    GoalEntry(
      title: 'Read 12 books this year',
      importance: Importance.low,
      owner: EntryOwner.me,
    ),
    GoalEntry(
      title: 'Run a 5k under 25 minutes',
      importance: Importance.medium,
      owner: EntryOwner.partner,
    ),
    GoalEntry(
      title: 'Save €5,000 for the Japan trip',
      importance: Importance.high,
      description: 'Split evenly, check in on progress monthly.',
      owner: EntryOwner.shared,
    ),
    GoalEntry(
      title: 'Learn to bake sourdough',
      importance: Importance.low,
      owner: EntryOwner.me,
    ),
    TaskEntry(
      title: 'Call the landlord',
      startDate: at(0, 11, 0),
      importance: Importance.high,
      owner: EntryOwner.me,
    ),
    TaskEntry(
      title: 'Pick up dry cleaning',
      startDate: at(0, 16, 0),
      owner: EntryOwner.me,
    ),
    TaskEntry(
      title: 'Gym session',
      startDate: at(-1, 7, 0),
      owner: EntryOwner.partner,
    ),
    TaskEntry(
      title: 'Reply to Sam\'s email',
      startDate: at(0, 15, 0),
      owner: EntryOwner.partner,
    ),
    TaskEntry(
      title: 'Choose a restaurant',
      startDate: at(0, 12, 0),
      owner: EntryOwner.shared,
    ),
    TaskEntry(
      title: 'Book dentist appointment',
      startDate: at(1, 10, 30),
      owner: EntryOwner.me,
    ),
    TaskEntry(
      title: 'Fix bike brakes',
      startDate: at(2, 17, 0),
      importance: Importance.low,
      owner: EntryOwner.partner,
    ),
    TaskEntry(
      title: 'Grocery shopping',
      startDate: at(0, 18, 0),
      description: 'Milk, eggs, the good coffee.',
      owner: EntryOwner.shared,
    ),
    TaskEntry(
      title: 'Submit expense report',
      startDate: at(4, 12, 0),
      importance: Importance.high,
      owner: EntryOwner.me,
    ),
    TaskEntry(
      title: 'Renew car insurance',
      startDate: at(5, 9, 0),
      importance: Importance.high,
      owner: EntryOwner.partner,
    ),
    TaskEntry(
      title: 'Plan weekend trip to the coast',
      startDate: at(6, 20, 0),
      owner: EntryOwner.shared,
    ),
    TaskEntry(
      title: 'Call mum',
      startDate: at(1, 19, 0),
      description: 'Ask about Sunday lunch.',
      owner: EntryOwner.me,
    ),
    TaskEntry(
      title: 'Oil change for the car',
      startDate: at(9, 11, 0),
      owner: EntryOwner.partner,
    ),
    TaskEntry(
      title: 'Finish quarterly report',
      startDate: at(3, 17, 30),
      importance: Importance.high,
      owner: EntryOwner.me,
    ),
    TaskEntry(
      title: 'Water the plants',
      startDate: at(0, 8, 0),
      importance: Importance.low,
      owner: EntryOwner.partner,
    ),
    EventEntry(
      title: 'Focus block',
      startDate: at(0, 10, 0),
      endDate: at(0, 12, 0),
      owner: EntryOwner.me,
    ),
    EventEntry(
      title: 'Lunch with Nia',
      startDate: at(0, 13, 0),
      endDate: at(0, 14, 0),
      owner: EntryOwner.me,
    ),
    EventEntry(
      title: 'Client standup',
      startDate: at(0, 9, 30),
      endDate: at(0, 10, 0),
      owner: EntryOwner.partner,
    ),
    EventEntry(
      title: 'Gym',
      startDate: at(0, 18, 0),
      endDate: at(0, 19, 0),
      owner: EntryOwner.partner,
    ),
    EventEntry(
      title: 'Walk the canal',
      startDate: at(0, 16, 30),
      endDate: at(0, 17, 30),
      owner: EntryOwner.shared,
    ),
    EventEntry(
      title: 'Date night — dinner reservation',
      startDate: at(0, 19, 0),
      endDate: at(0, 21, 0),
      importance: Importance.high,
      owner: EntryOwner.shared,
    ),
    EventEntry(
      title: 'Yoga class',
      startDate: at(1, 8, 0),
      endDate: at(1, 9, 0),
      owner: EntryOwner.me,
    ),
    EventEntry(
      title: '5-a-side football',
      startDate: at(3, 19, 0),
      endDate: at(3, 20, 30),
      people: const ['Dave', 'Sam'],
      owner: EntryOwner.partner,
    ),
    EventEntry(
      title: 'Anniversary dinner',
      startDate: at(10, 19, 30),
      endDate: at(10, 22, 0),
      importance: Importance.high,
      description: 'The little Italian place she loves.',
      owner: EntryOwner.shared,
    ),
    EventEntry(
      title: 'Book club meeting',
      startDate: at(7, 18, 30),
      endDate: at(7, 20, 0),
      people: const ['Sarah', 'Priya'],
      owner: EntryOwner.me,
    ),
    EventEntry(
      title: 'Poker night',
      startDate: at(8, 20, 0),
      endDate: at(8, 23, 0),
      people: const ['Tom', 'Jake', 'Leo'],
      owner: EntryOwner.partner,
    ),
    EventEntry(
      title: 'Movie night at home',
      startDate: at(2, 20, 30),
      endDate: at(2, 22, 30),
      owner: EntryOwner.shared,
    ),
  ];
}
