import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduquiz/app.dart';

void main() {
  testWidgets('EduQuiz login smoke test', (tester) async {
    await tester.pumpWidget(const EduQuizApp());

    expect(find.text('EduQuiz'), findsWidgets);
    expect(find.text('Masuk Pengguna'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Risma');
    await tester.enterText(find.byType(TextField).at(1), 'risma@example.com');
    await tester.tap(find.text('Masuk ke EduQuiz'));
    await tester.pumpAndSettle();

    expect(find.text('Ruang Peserta'), findsOneWidget);
    expect(find.text('Fitur Utama'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Logout dari EduQuiz?'), findsOneWidget);
  });
}
