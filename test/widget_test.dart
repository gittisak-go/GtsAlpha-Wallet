import 'package:flutter_test/flutter_test.dart';
import 'package:gtsalpha_wallet/main.dart';

void main() {
  testWidgets('ScanApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScanApp());

    // Verify that the scan screen is shown
    expect(find.text('GtsAlpha Wallet'), findsWidgets);
    expect(find.text('แตะการ์ดหรือสแกน QR Code\nเพื่อเริ่มต้นใช้งาน'), findsOneWidget);
  });
}
