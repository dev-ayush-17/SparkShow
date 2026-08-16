import 'package:flutter_test/flutter_test.dart';
import 'package:fireworks_showcase/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const FireworksShowcaseApp());
    await tester.pumpAndSettle();

    expect(find.text('Fireworks Showcase'), findsOneWidget);
  });
}
