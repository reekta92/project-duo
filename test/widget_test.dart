import 'package:flutter_test/flutter_test.dart';
import 'package:project_duo/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const VocabGameApp());
    await tester.pump();

    expect(find.text('Kelime Oyunu'), findsOneWidget);
    expect(find.text('Tekrar Hoş Geldin'), findsOneWidget);
  });
}
