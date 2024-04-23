import 'package:exif_helper/widgets/my_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createMySliverAppbarScreen({String? title}) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            MySliverAppBar(title: title),
          ],
        ),
      ),
    );
  }

  group('MySliverAppBar', () {
    String title = "Test My Sliver App Bar";
    testWidgets('builds a sliver app bar with a title',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMySliverAppbarScreen(title: title));
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('builds a sliver app bar without a title when title is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMySliverAppbarScreen());
      expect(find.text(title), findsNothing);
    });
  });
}
