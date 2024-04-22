import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exif_helper/common/utils.dart';

void main() {
  const String message = "Test message";
  late Widget widget;

  setUp(() {
    widget = MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(),
        ),
      ),
    );
  });

  group("test SnackBarUtils show correctly", () {
    testWidgets(
        'SnackBarUtils.showSnackBar displays a SnackBar with the given message',
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      final context = tester.element(find.byType(Scaffold));
      SnackBarUtils.showSnackBar(context, message);
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.widgetWithText(SnackBar, message), findsOneWidget);
    });

    testWidgets(
        'SnackBarUtils.showSnackBar displays the SnackBar for the specified duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      final context = tester.element(find.byType(Scaffold));
      const duration = Duration(seconds: 3);
      SnackBarUtils.showSnackBar(context, message, duration: duration);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
