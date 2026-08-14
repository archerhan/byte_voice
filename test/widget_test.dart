import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byte_voice/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ByteVoiceApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
