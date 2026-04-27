import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tantsaha_market/main.dart';
import 'package:tantsaha_market/providers/market_provider.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => MarketProvider())],
        child: const TantsahaMarketApp(),
      ),
    );
    expect(find.byType(TantsahaMarketApp), findsOneWidget);
  });
}
