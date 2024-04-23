import 'package:exif_helper/widgets/desktop_image_panel.dart';
import 'package:exif_helper/widgets/image_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_drop/desktop_drop.dart';

void main() {
  testWidgets('test DesktopImagePanel builds correctly',
      (WidgetTester tester) async {
    const imagePath = 'test/test_image.jpg';
    const widget = DesktopImagePanel(
      imagePath: imagePath,
    );
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    ));
    expect(find.byType(DropTarget), findsOneWidget);
    widget.onDragEntered?.call(DropEventDetails(
      localPosition: const Offset(0, 0),
      globalPosition: const Offset(0, 0),
    ));
    widget.onDragUpdated?.call(
      DropEventDetails(
        localPosition: const Offset(10, 10),
        globalPosition: const Offset(10, 10),
      ),
    );
    widget.onDragDone?.call(imagePath);
    await tester.pumpAndSettle();
    expect(find.byType(ImagePanel), findsOneWidget);
    widget.onDragExited?.call(DropEventDetails(
      localPosition: const Offset(10, 10),
      globalPosition: const Offset(10, 10),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(ImagePanel), findsOneWidget);
  });
}
