// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehabiltiation/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('더하기 버튼이 정상 작동하는지 테스트', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임을 트리거합니다.
    await tester.pumpWidget(const MyApp());

    // 초기 카운터 값이 0인지 확인합니다.
    expect(find.text('0'), findsOneWidget);

    // 더하기 버튼을 찾아 탭합니다.
    final incrementButton = find.byIcon(Icons.add);
    expect(incrementButton, findsOneWidget);

    // 더하기 버튼을 한 번 탭합니다.
    await tester.tap(incrementButton);
    await tester.pump();

    // 카운터가 1로 증가했는지 확인합니다.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    // 더하기 버튼을 다시 한 번 탭합니다.
    await tester.tap(incrementButton);
    await tester.pump();

    // 카운터가 2로 증가했는지 확인합니다.
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);

    // 더하기 버튼을 세 번째로 탭합니다.
    await tester.tap(incrementButton);
    await tester.pump();

    // 카운터가 3으로 증가했는지 확인합니다.
    expect(find.text('2'), findsNothing);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('빼기 버튼이 정상 작동하는지 테스트', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임을 트리거합니다.
    await tester.pumpWidget(const MyApp());

    // 초기 카운터 값이 0인지 확인합니다.
    expect(find.text('0'), findsOneWidget);

    // 빼기 버튼을 찾아 탭합니다.
    final decrementButton = find.byIcon(Icons.remove);
    expect(decrementButton, findsOneWidget);

    // 빼기 버튼을 한 번 탭합니다 (0에서 빼기 버튼을 눌러도 0이 유지되어야 함).
    await tester.tap(decrementButton);
    await tester.pump();

    // 카운터가 0으로 유지되는지 확인합니다.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('-1'), findsNothing);

    // 더하기 버튼을 눌러서 1로 만듭니다.
    final incrementButton = find.byIcon(Icons.add);
    await tester.tap(incrementButton);
    await tester.pump();

    // 카운터가 1인지 확인합니다.
    expect(find.text('1'), findsOneWidget);

    // 빼기 버튼을 한 번 탭합니다.
    await tester.tap(decrementButton);
    await tester.pump();

    // 카운터가 0으로 감소했는지 확인합니다.
    expect(find.text('1'), findsNothing);
    expect(find.text('0'), findsOneWidget);

    // 빼기 버튼을 다시 한 번 탭합니다 (0에서 빼기 버튼을 눌러도 0이 유지되어야 함).
    await tester.tap(decrementButton);
    await tester.pump();

    // 카운터가 0으로 유지되는지 확인합니다.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('-1'), findsNothing);
  });

  testWidgets('더하기와 빼기 버튼이 함께 정상 작동하는지 테스트', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임을 트리거합니다.
    await tester.pumpWidget(const MyApp());

    // 초기 카운터 값이 0인지 확인합니다.
    expect(find.text('0'), findsOneWidget);

    final incrementButton = find.byIcon(Icons.add);
    final decrementButton = find.byIcon(Icons.remove);

    // 더하기 버튼을 3번 탭합니다.
    await tester.tap(incrementButton);
    await tester.pump();
    await tester.tap(incrementButton);
    await tester.pump();
    await tester.tap(incrementButton);
    await tester.pump();

    // 카운터가 3인지 확인합니다.
    expect(find.text('3'), findsOneWidget);

    // 빼기 버튼을 2번 탭합니다.
    await tester.tap(decrementButton);
    await tester.pump();
    await tester.tap(decrementButton);
    await tester.pump();

    // 카운터가 1인지 확인합니다.
    expect(find.text('3'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    // 더하기 버튼을 1번 탭합니다.
    await tester.tap(incrementButton);
    await tester.pump();

    // 카운터가 2인지 확인합니다.
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);

    // 빼기 버튼을 3번 탭합니다 (2에서 3번 빼면 0이 되어야 함).
    await tester.tap(decrementButton);
    await tester.pump();
    await tester.tap(decrementButton);
    await tester.pump();
    await tester.tap(decrementButton);
    await tester.pump();

    // 카운터가 0인지 확인합니다 (0 미만으로 가지 않음).
    expect(find.text('2'), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('-1'), findsNothing);
  });

  testWidgets('플로팅 버튼이 화면에 표시되는지 테스트', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임을 트리거합니다.
    await tester.pumpWidget(const MyApp());

    // 더하기 버튼이 존재하는지 확인합니다.
    expect(find.byIcon(Icons.add), findsOneWidget);

    // 빼기 버튼이 존재하는지 확인합니다.
    expect(find.byIcon(Icons.remove), findsOneWidget);

    // 두 버튼이 모두 FloatingActionButton인지 확인합니다.
    expect(find.byType(FloatingActionButton), findsNWidgets(2));
  });
}
