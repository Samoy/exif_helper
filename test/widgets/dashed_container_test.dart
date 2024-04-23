import 'package:exif_helper/widgets/dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'DashedContainer should paint dashed border with gap greater than 0',
      (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: Scaffold(
        body: Center(
          child: DashedContainer(
            width: 100,
            height: 100,
            borderColor: Colors.black,
            strokeWidth: 2,
            gap: 5,
          ),
        ),
      ),
    );
    await tester.pumpWidget(testWidget);
    await expectLater(
        find.byType(DashedContainer),
        matchesGoldenFile(
            'goldens/dashed_container_expected_result_greater_than_0.png'));
  });

  testWidgets("DashedContainer should paint dashed border with gap less than 0",
      (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: Scaffold(
        body: Center(
          child: DashedContainer(
            width: 100,
            height: 100,
            borderColor: Colors.black,
            strokeWidth: 2,
            gap: -5,
          ),
        ),
      ),
    );
    await tester.pumpWidget(testWidget);
    await expectLater(
        find.byType(DashedContainer),
        matchesGoldenFile(
            'goldens/dashed_container_expected_result_less_than_0.png'));
  });
}
