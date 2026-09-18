import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/main.dart';
import 'package:todo_list/widgets/calendar/day_cell.dart';
import 'package:todo_list/widgets/glass/todo_sticker.dart';

void _setMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save').last);
  await tester.pumpAndSettle();
}

Finder _checkboxFor(String title) {
  return find.descendant(
    of: find.ancestor(of: find.text(title), matching: find.byType(TodoSticker)),
    matching: find.byType(Checkbox),
  );
}

Future<void> _swipeFrom(WidgetTester tester, Key edge, Offset delta) async {
  final rect = tester.getRect(find.byKey(edge));
  await tester.timedDragFrom(rect.center, delta, const Duration(milliseconds: 280));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Day board is paper plus calendar, with lists off the page', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    expect(find.textContaining('today'), findsOneWidget);
    expect(find.text('← swipe an edge for to-dos →'), findsOneWidget);
    expect(find.text('Focus block'), findsNothing);
    expect(find.text('Client standup'), findsNothing);
    expect(find.text('Date night — dinner reservation'), findsNothing);
    expect(find.text('Call the landlord'), findsNothing);

    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    expect(find.text('${months[now.month - 1]} ${now.year}'), findsOneWidget);
  });

  testWidgets('To-dos stay off the board until you swipe a glass sheet in', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Call the landlord'), findsNothing);
    expect(find.text('Reply to Sam\'s email'), findsNothing);
    expect(find.text('Choose a restaurant'), findsNothing);

    await _swipeFrom(tester, const Key('edge-left'), const Offset(280, 0));

    expect(find.text('Call the landlord'), findsOneWidget);
    expect(find.text('Focus block'), findsOneWidget);
    expect(find.text('Your to-dos'), findsOneWidget);
    expect(find.text('Reply to Sam\'s email'), findsNothing);

    expect(
      tester.getTopLeft(find.text('Call the landlord')).dy,
      lessThan(tester.getTopLeft(find.text('Pick up dry cleaning')).dy),
    );
  });

  testWidgets('Partner glass stacks on yours and is the only one you can swipe away', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    await _swipeFrom(tester, const Key('edge-left'), const Offset(280, 0));
    expect(find.text('Call the landlord'), findsOneWidget);

    await _swipeFrom(tester, const Key('edge-right'), const Offset(-280, 0));
    expect(find.text('Reply to Sam\'s email'), findsOneWidget);

    // Same clock time covers; different hours stay apart on the paper.
    expect(
      tester.getTopLeft(find.text('Call the landlord')).dy,
      lessThan(tester.getTopLeft(find.text('Reply to Sam\'s email')).dy),
    );
    expect(find.text("Partner's to-dos"), findsOneWidget);
    // Yours stay underneath the red acetate.
    expect(find.text('Call the landlord'), findsOneWidget);

    // Left-edge swipe cannot dismiss the buried blue sheet.
    await _swipeFrom(tester, const Key('edge-left'), const Offset(-280, 0));
    expect(find.text('Call the landlord'), findsOneWidget);
    expect(find.text('Reply to Sam\'s email'), findsOneWidget);

    // Anywhere on the top sheet (except other reveal edges) swipes it away.
    await tester.timedDragFrom(
      const Offset(200, 520),
      const Offset(220, 0),
      const Duration(milliseconds: 280),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reply to Sam\'s email'), findsNothing);
    expect(find.text('Call the landlord'), findsOneWidget);
  });

  testWidgets('Pressing an edge peeks the glass, releasing tucks it away', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    final edge = tester.getRect(find.byKey(const Key('edge-left')));
    final gesture = await tester.startGesture(edge.center);
    await tester.pump();

    expect(find.text('Your to-dos'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Your to-dos'), findsNothing);
    expect(find.text('Call the landlord'), findsNothing);
  });

  testWidgets('Group glass comes down from the top with shared to-dos', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    await _swipeFrom(tester, const Key('edge-top'), const Offset(0, 800));
    expect(find.text('Choose a restaurant'), findsOneWidget);
    expect(find.text('Group to-dos'), findsOneWidget);
    expect(find.text('Call the landlord'), findsNothing);
  });

  testWidgets('Add a task via the centre button and tick it on the glass', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();

    expect(find.text('New entry'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Buy milk');
    await _tapSave(tester);

    expect(find.text('Buy milk'), findsNothing);

    await _swipeFrom(tester, const Key('edge-left'), const Offset(280, 0));
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

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('New entry'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('New entry'), findsNothing);
  });

  testWidgets('Tapping a calendar day changes the board date', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    if (tomorrow.month == today.month) {
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is DayCell && widget.day == tomorrow.day),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('today'), findsNothing);
    }

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is DayCell && widget.day == today.day),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('today'), findsOneWidget);
  });

  testWidgets('Description is hidden on the sticker but shown after tapping it', (
    WidgetTester tester,
  ) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const TodoApp());

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Buy milk');
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Oat milk, not almond',
    );
    await _tapSave(tester);

    await _swipeFrom(tester, const Key('edge-left'), const Offset(280, 0));
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('Oat milk, not almond'), findsNothing);

    await tester.tap(find.text('Buy milk'));
    await tester.pumpAndSettle();

    expect(find.text('Oat milk, not almond'), findsOneWidget);
  });
}
