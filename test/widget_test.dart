import 'package:flutter_test/flutter_test.dart';
import 'package:travio_1/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TravioApp());
    expect(find.byType(TravioApp), findsOneWidget);
  });
}
