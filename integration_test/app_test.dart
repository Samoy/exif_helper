import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exif_helper/main.dart' as app;

void main() {
  group('Test app if shows up correctly', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets('test MyApp if shows up correctly', (tester) async {
      await tester.runAsync(() => app.main());
      await tester.pumpAndSettle();
      expect(find.byType(app.MyApp), findsOneWidget);
    });
  });
}
