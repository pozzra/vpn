import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:vpn_one/main.dart';
import 'package:vpn_one/services/storage_service.dart';
import 'package:vpn_one/services/vpn_service.dart';

void main() {
  testWidgets('VPN One app renders home screen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VpnService(storage)),
        ],
        child: const VpnOneApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('VPN BY RXAA'), findsWidgets);
    expect(find.text('TAP TO CONNECT'), findsOneWidget);
    expect(find.text('Tunnel'), findsOneWidget);
    expect(find.text('Servers & IPs'), findsOneWidget);
  });
}
