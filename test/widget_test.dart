import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_vacation_1/main.dart';

void main() {
  testWidgets('MVP screen renders initial ritual UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MyFitVacationApp(enableVideo: false));

    expect(find.text('MORNING RITUAL'), findsOneWidget);
    expect(find.text('Clear the Bali Mist'), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('I DID A SQUAT ✅'), findsOneWidget);
  });
}
