import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:govprep/main.dart';

void main() {
  testWidgets('GovPrepApp loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GovPrepApp(),
      ),
    );

    // Verify that the initial route loads (GovPrep Home).
    expect(find.text('GovPrep Home'), findsOneWidget);
  });
}
