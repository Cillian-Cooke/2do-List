import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/main.dart';
import 'package:todo_list/widgets/whose_filter_button.dart';

void _setMobileViewport(WidgetTester tester) {
  // Tall enough that the (now longer, with the owner picker) form sheet
  // fits without needing a mid-test scroll to reach Save.
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// The form sheet can be taller than the test viewport, so the Save
/// button needs to be scrolled into view before tapping it.
Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save').last);
  await tester.pumpAndSettle();
}

/// The seed data means a plain `find.byType(Checkbox).first` doesn't
/// reliably land on the entry a test just created, so find the checkbox
/// inside the same card as its title instead.
Finder _checkboxFor(String title) {
  return find.descendant(
    of: find.ancestor(of: find.text(title), matching: find.byType(Card)),
    matching: find.byType(Checkbox),
  );
}

void main() {
  testWidgets('Add a task via the popup and mark it done', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Buy milk'), findsNothing);

    await tester.tap(find.text('Add to timeline'));
    await tester.pumpAndSettle();

    expect(find.text('New entry'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Buy milk');
    await _tapSave(tester);

    expect(find.text('Buy milk'), findsOneWidget);

    await tester.tap(_checkboxFor('Buy milk'));
    await tester.pump();

    final checkbox = tester.widget<Checkbox>(_checkboxFor('Buy milk'));
    expect(checkbox.value, isTrue);
  });

  testWidgets('Tapping outside the popup dismisses it without adding', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    await tester.tap(find.text('Add to timeline'));
    await tester.pumpAndSettle();
    expect(find.text('New entry'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('New entry'), findsNothing);
  });

  testWidgets('Tapping an entry\'s day in the calendar filters the list', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    await tester.tap(find.text('Add to timeline'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Team sync');
    await _tapSave(tester);

    expect(find.text('Team sync'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Team sync'), findsNothing);

    await tester.tap(find.text('${DateTime.now().day}').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Showing'), findsOneWidget);
    expect(find.text('Team sync'), findsOneWidget);

    await tester.tap(find.text('Show all'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Showing'), findsNothing);
  });

  testWidgets('Description is hidden in the list but shown after tapping the task', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    await tester.tap(find.text('Add to timeline'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Buy milk');
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Oat milk, not almond',
    );
    await _tapSave(tester);

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('Oat milk, not almond'), findsNothing);

    await tester.tap(find.text('Buy milk'));
    await tester.pumpAndSettle();

    expect(find.text('Oat milk, not almond'), findsOneWidget);
  });

  testWidgets('Goals have no date option, are pinned above tasks, and tick off', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    // Create a goal: switching type to Goal hides the Date section.
    await tester.tap(find.text('Add to timeline'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Goal'));
    await tester.pump();
    expect(find.text('Date'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Learn Flutter');
    await _tapSave(tester);

    expect(find.text('Learn Flutter'), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);

    // Add a dated task; the goal should still be pinned above it.
    await tester.tap(find.text('Add to timeline'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Write report');
    await _tapSave(tester);

    expect(find.text('Write report'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Learn Flutter')).dy,
      lessThan(tester.getCenter(find.text('Write report')).dy),
    );

    // Ticking the goal off shows a strikethrough.
    await tester.tap(_checkboxFor('Learn Flutter'));
    await tester.pump();

    final goalCheckbox = tester.widget<Checkbox>(_checkboxFor('Learn Flutter'));
    expect(goalCheckbox.value, isTrue);
  });

  testWidgets('Both/Mine/Theirs filter shows the right owners', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    final whoseFilterButton = find.byType(WhoseFilterButton);

    // Seeded data includes both owners; "Both" (default) shows everything.
    expect(find.text('Gym session'), findsOneWidget); // partner-owned
    expect(find.text('Book dentist appointment'), findsOneWidget); // me-owned

    await tester.tap(whoseFilterButton); // both -> mine
    await tester.pumpAndSettle();

    expect(find.text('Book dentist appointment'), findsOneWidget);
    expect(find.text('Gym session'), findsNothing);

    await tester.tap(whoseFilterButton); // mine -> theirs
    await tester.pumpAndSettle();

    expect(find.text('Gym session'), findsOneWidget);
    expect(find.text('Book dentist appointment'), findsNothing);

    await tester.tap(whoseFilterButton); // theirs -> both
    await tester.pumpAndSettle();
    await tester.tap(whoseFilterButton); // both -> mine
    await tester.pumpAndSettle();

    // Shared entries show under both filters.
    expect(find.text('Grocery shopping'), findsOneWidget);
  });
}
