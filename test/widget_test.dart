import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/main.dart';

void main() {
  testWidgets('Add a todo and mark it done', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('No tasks yet. Add one above!'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('No tasks yet. Add one above!'), findsNothing);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
  });
}
