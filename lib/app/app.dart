import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/device/data/raspberry_pi_device.dart';
import '../features/device/domain/reader_device.dart';
import '../features/files/presentation/files_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/output/presentation/output_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/session/data/session_storage.dart';
import '../features/session/presentation/session_start_screen.dart';
import '../shared/widgets/alien_header.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/models/document_output.dart';
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
  final RaspberryPiDevice _device = RaspberryPiDevice();
  final SessionStorage _sessionStorage = SessionStorage();

  late final StreamSubscription<ReaderConnectionStatus> _statusSub;

  ReaderConnectionStatus _status =
      ReaderConnectionStatus.disconnected;

  MainTab _tab = MainTab.home;

  int _pageCount = 0;

  bool _sessionStarted = false;
  bool _isLoadingSession = true;
  bool _isCapturing = false;
  bool _isConnecting = false;

  String? _userName;

  @override
  void initState() {
    super.initState();

    _statusSub = _device.status.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });

    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    final userName = await _sessionStorage.getUserName();
    final connected = await _sessionStorage.isConnected();
    final pageCount = await _sessionStorage.getPageCount();

    if (!mounted) return;

    setState(() {
      _userName = userName;
      _pageCount = pageCount;

      if (userName != null && userName.isNotEmpty && connected) {
        _sessionStarted = true;
        _status = ReaderConnectionStatus.connected;
      }

      _isLoadingSession = false;
    });
  }

  @override
  void dispose() {
    _statusSub.cancel();
    _device.dispose();
    super.dispose();
  }

  Future<void> _onSessionStarted(
    String userName,
    String? accessToken,
  ) async {
    setState(() {
      _userName = userName;
      _sessionStarted = true;
      _status = ReaderConnectionStatus.disconnected;
    });

    await _connect();
  }

  Future<void> _connect() async {
    if (_userName == null || _userName!.isEmpty) {
      return;
    }

    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _status = ReaderConnectionStatus.connecting;
    });

    try {
      await _device.startSession(_userName!);

      await _sessionStorage.saveSession(
        userName: _userName!,
        connected: true,
        pageCount: _pageCount,
      );

      if (!mounted) return;

      setState(() {
        _status = ReaderConnectionStatus.connected;
        _sessionStarted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connected as $_userName',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = ReaderConnectionStatus.disconnected;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _capture() async {
    if (_isCapturing) return;

    if (_status != ReaderConnectionStatus.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect to the Raspberry Pi first'),
        ),
      );
      return;
    }

    setState(() {
      _isCapturing = true;
      _status = ReaderConnectionStatus.busy;
    });

    try {
      await _device.capture();

      if (!mounted) return;

      final newPageCount = _pageCount + 1;

      setState(() {
        _pageCount = newPageCount;
        _status = ReaderConnectionStatus.connected;
      });

      await _sessionStorage.savePageCount(newPageCount);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Page $_pageCount captured and processed successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = ReaderConnectionStatus.connected;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await _device.endSession();
    } catch (_) {
      // Even if the request fails, clear the local session.
    }

    await _sessionStorage.clearSession();

    if (!mounted) return;

    setState(() {
      _sessionStarted = false;
      _userName = null;
      _pageCount = 0;
      _status = ReaderConnectionStatus.disconnected;
      _tab = MainTab.home;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disconnected from Raspberry Pi'),
      ),
    );
  }

  Future<void> _process() async {
    if (!mounted) return;

    // Read the last capture result stored by RaspberryPiDevice.capture().
    // POST /capture returns: image_url, text, summary, original_audio_url,
    // summary_audio_url — all pre-processed on the Pi (OCR + Gemini).
    final capture = _device.lastCapture;

    if (capture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No pages captured yet. '
            'Capture a document first.',
          ),
        ),
      );
      return;
    }

    // Build real DocumentOutput from the Pi API response.
    final imageRawUrl = capture['image_url'] as String?;
    final originalText =
        ((capture['text'] as String?) ?? '').trim();
    final summaryText =
        ((capture['summary'] as String?) ?? '').trim();
    final originalAudioRaw =
        capture['original_audio_url'] as String?;
    final summaryAudioRaw =
        capture['summary_audio_url'] as String?;

    final output = DocumentOutput(
      originalText: originalText.isNotEmpty
          ? originalText
          : 'No readable text was detected in this document.',
      summaryText: summaryText.isNotEmpty
          ? summaryText
          : 'No AI summary could be generated.',
      imageUrl: (imageRawUrl != null && imageRawUrl.isNotEmpty)
          ? _device.getFullUrl(imageRawUrl)
          : null,
      originalAudioUrl:
          (originalAudioRaw != null && originalAudioRaw.isNotEmpty)
              ? _device.getFullUrl(originalAudioRaw)
              : null,
      summaryAudioUrl:
          (summaryAudioRaw != null && summaryAudioRaw.isNotEmpty)
              ? _device.getFullUrl(summaryAudioRaw)
              : null,
    );

    await Navigator.of(context).pushNamed(
      AppRoutes.processing,
      arguments: () async {
        await Navigator.of(context).pushReplacementNamed(
          AppRoutes.documentResults,
          arguments: output, // real data
        );

        if (mounted) {
          setState(() {
            _pageCount = 0;
          });

          await _sessionStorage.savePageCount(0);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_sessionStarted) {
      return SessionStartScreen(
        onSessionStarted: _onSessionStarted,
      );
    }

    return Scaffold(
      appBar: AlienHeader(
        onOpenSettings: () {
          _showConnectionDialog();
        },
      ),
      body: IndexedStack(
        index: MainTab.values.indexOf(_tab),
        children: [
          HomeScreen(
            status: _status,
            onConnect: _connect,
            onCapture: _capture,
            onFinish: _process,
            pageCount: _pageCount,
            onDeletePage: () async {
              if (_pageCount <= 0) return;

              final newPageCount = _pageCount - 1;

              setState(() {
                _pageCount = newPageCount;
              });

              await _sessionStorage.savePageCount(newPageCount);
            },
          ),
          const OutputScreen(),
          FilesScreen(device: _device),
          ProfileScreen(
                  userName: _userName,
                  status: _status,
                  pageCount: _pageCount,
                  sessionActive: _sessionStarted,
                ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentTab: _tab,
        onChanged: (tab) {
          setState(() {
            _tab = tab;
          });
        },
      ),
    );
  }

  void _showConnectionDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.memory,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Raspberry Pi Connection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  _status == ReaderConnectionStatus.connected
                      ? 'Connected'
                      : 'Disconnected',
                  style: TextStyle(
                    fontSize: 16,
                    color: _status == ReaderConnectionStatus.connected
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'User: ${_userName ?? 'Unknown'}',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _disconnect();
                    },
                    icon: const Icon(Icons.link_off),
                    label: const Text('DISCONNECT'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
