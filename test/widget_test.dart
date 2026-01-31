import 'package:flutter_test/flutter_test.dart';
import 'package:scan_app/main.dart';

void main() {
  testWidgets('ScanApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScanApp());

    // Verify that the scan screen is shown
    expect(find.text('สแกน QR / NFC'), findsOneWidget);
    expect(find.text('พร้อมที่จะสแกน'), findsOneWidget);
  });
}
