import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alien_reader_app/features/device/domain/reader_device.dart';
import 'package:alien_reader_app/features/home/presentation/home_screen.dart';

void main() {
  group('HomeScreen Layout & Priority Order Tests', () {
    testWidgets('renders first section: Connect via Wi-Fi / Scan QR card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              status: ReaderConnectionStatus.disconnected,
              onConnect: () {},
              onCapture: () {},
              onFinish: () {},
              pageCount: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Connect via Wi-Fi / Scan QR'), findsOneWidget);
      expect(
        find.text('Scan your Naadh device QR to connect or configure Wi-Fi'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
      expect(find.byIcon(Icons.wifi_rounded), findsOneWidget);
    });

    testWidgets('renders Live Camera section with compact Connect to Device button when disconnected', (
      WidgetTester tester,
    ) async {
      var connectPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              status: ReaderConnectionStatus.disconnected,
              onConnect: () => connectPressed = true,
              onCapture: () {},
              onFinish: () {},
              pageCount: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Camera'), findsOneWidget);
      expect(find.text('Disconnected'), findsOneWidget);
      expect(find.text('Connect to Device'), findsOneWidget);

      await tester.tap(find.text('Connect to Device'));
      expect(connectPressed, isTrue);

      // Verify removed items are NOT present
      expect(find.text('Raspberry Pi Feed'), findsNothing);
      expect(find.text('Recent Documents'), findsNothing);
      expect(find.text('Quick Shortcuts'), findsNothing);
    });

    testWidgets('renders Connected status and Disconnect option when connected', (
      WidgetTester tester,
    ) async {
      var disconnectPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              status: ReaderConnectionStatus.connected,
              onConnect: () {},
              onDisconnect: () => disconnectPressed = true,
              onCapture: () {},
              onFinish: () {},
              pageCount: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Camera'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Connected to Naadh Reader'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);

      await tester.tap(find.text('Disconnect'));
      expect(disconnectPressed, isTrue);
    });

    testWidgets('renders Capture Page and Process buttons with correct states', (
      WidgetTester tester,
    ) async {
      var capturePressed = false;
      var processPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              status: ReaderConnectionStatus.connected,
              onConnect: () {},
              onCapture: () => capturePressed = true,
              onFinish: () => processPressed = true,
              pageCount: 2,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Capture Page'), findsOneWidget);
      expect(find.text('Process'), findsOneWidget);

      await tester.tap(find.text('Capture Page'));
      expect(capturePressed, isTrue);

      await tester.tap(find.text('Process'));
      expect(processPressed, isTrue);
    });

    testWidgets('renders Captured Pages strip with thumbnails and count badge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              status: ReaderConnectionStatus.connected,
              onConnect: () {},
              onCapture: () {},
              onFinish: () {},
              pageCount: 3,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Captured Pages'), findsOneWidget);
      expect(find.text('3 Pages'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 3'), findsOneWidget);
    });

    testWidgets('renders subtle empty state when no pages captured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              status: ReaderConnectionStatus.connected,
              onConnect: () {},
              onCapture: () {},
              onFinish: () {},
              pageCount: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No pages captured yet'), findsOneWidget);
      expect(find.text('0 Pages'), findsOneWidget);
    });
  });
}

