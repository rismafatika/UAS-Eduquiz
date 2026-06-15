import 'package:flutter_test/flutter_test.dart';
import 'package:eduquiz/app.dart';

void main() {
  testWidgets('EduQuiz app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const EduQuizApp());

    expect(find.byType(EduQuizApp), findsOneWidget);
  });
}