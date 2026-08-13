import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/device/data/mock_reader_device.dart';
import '../features/device/domain/reader_device.dart';
import '../features/files/presentation/files_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/output/presentation/output_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../shared/widgets/alien_header.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/widgets/mock_audio_player.dart';
import 'router.dart';

class AlienReaderApp extends StatelessWidget {
  const AlienReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.light,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final MockReaderDevice _device = MockReaderDevice();
  late final StreamSubscription<ReaderConnectionStatus> _statusSub;
  ReaderConnectionStatus _status = ReaderConnectionStatus.connecting;
  MainTab _tab = MainTab.home;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _statusSub = _device.status.listen((status) {
      if (mounted) {
        setState(() => _status = status);
      }
    });
  }

  @override
  void dispose() {
    _statusSub.cancel();
    _device.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    await _device.capture();
    if (!mounted) return;
    setState(() => _pageCount++);
  }

  Future<void> _finish() async {
    await _device.finishScan();
    if (!mounted) return;

    await Navigator.of(context).pushNamed(
      AppRoutes.processing,
      arguments: () async {
        await Navigator.of(context).pushReplacementNamed(
          AppRoutes.documentResults,
          arguments: mockOutput,
        );
        if (mounted) setState(() => _pageCount = 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AlienHeader(
        onOpenSettings: () =>
            Navigator.of(context).pushNamed(AppRoutes.settings),
      ),
      body: IndexedStack(
        index: MainTab.values.indexOf(_tab),
        children: [
          HomeScreen(
            status: _status,
            onCapture: _capture,
            onFinish: _finish,
            pageCount: _pageCount,
            onDeletePage: () {
              if (mounted) {
                setState(() {
                  if (_pageCount > 0) {
                    _pageCount--;
                  }
                });
              }
            },
          ),
          const OutputScreen(),
          const FilesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentTab: _tab,
        onChanged: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}
