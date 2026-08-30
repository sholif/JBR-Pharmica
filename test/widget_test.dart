import 'package:flutter_test/flutter_test.dart';
import 'package:jbr_pharmica/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JbrPharmicaApp());
    expect(find.text('Clinical Reference'), findsOneWidget);
  });
}
