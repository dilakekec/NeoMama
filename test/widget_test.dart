import 'package:flutter_test/flutter_test.dart';
import 'package:neomama/neomama_app.dart';

void main() {
  testWidgets('NeoMamaApp builds', (tester) async {
    await tester.pumpWidget(const NeoMamaApp());
    expect(find.byType(NeoMamaApp), findsOneWidget);
  });
}