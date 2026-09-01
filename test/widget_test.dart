import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jbr_pharmica/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JbrPharmicaApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(JbrPharmicaApp), findsOneWidget);
  });
}
