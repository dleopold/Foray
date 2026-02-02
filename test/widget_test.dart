import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:foray/app.dart';
import 'package:foray/database/database.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const ForayApp(),
      ),
    );

    expect(find.text('My Forays'), findsWidgets);
  });
}
