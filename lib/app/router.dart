import 'package:flutter/material.dart';

import '../features/document/presentation/document_results_screen.dart';
import '../features/processing/presentation/processing_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../shared/models/document_output.dart';

abstract final class AppRoutes {
  static const settings = '/settings';
  static const processing = '/processing';
  static const documentResults = '/document-results';
}

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case AppRoutes.processing:
        final callback = settings.arguments as VoidCallback;
        return MaterialPageRoute<void>(
          builder: (_) => ProcessingScreen(onCompleted: callback),
          settings: settings,
        );
      case AppRoutes.documentResults:
        final output = settings.arguments as DocumentOutput;
        return MaterialPageRoute<void>(
          builder: (_) => DocumentResultsScreen(output: output),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
