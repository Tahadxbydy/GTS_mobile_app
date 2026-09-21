// lib/core/navigation/navigation_service.dart
import 'package:flutter/material.dart';

import '../views/widgets/custom_loader_dialog.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static bool _isDialogOpen = false;

  static bool get isDialogOpen => _isDialogOpen;

  static const _duration = Duration(seconds: 4);

  static Future<void> _showOverlay(
    Widget dialog, {
    bool barrierDismissible = true,
    Duration? autoDismissDuration,
  }) async {
    final currentContext = context;
    if (currentContext == null) return;

    if (_isDialogOpen) {
      hide();
    }

    _isDialogOpen = true;

    // Optional timer to auto-dismiss dialog after duration
    if (autoDismissDuration != null) {
      Future.delayed(_duration, () {
        if (_isDialogOpen) {
          hide();
        }
      });
    }

    await showDialog(
      context: currentContext,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );

    _isDialogOpen = false;
  }

  /// 1. Shows a loading dialog overlay (non-dismissible)
  static void showLoading({String message = 'Loading...'}) {
    _showOverlay(
      CustomLoaderDialog(message: message),
      barrierDismissible: false,
    );
  }

  /// 2. Shows an informational message dialog (Auto-dismisses in 10s)
  static void showMessage({required String title, required String message}) {
    _showOverlay(
      AlertDialog(title: Text(title), content: Text(message)),
      autoDismissDuration: _duration,
    );
  }

  /// 3. Shows an error alert dialog (Auto-dismisses in 10s)
  static void showError({String title = 'Error', required String message}) {
    _showOverlay(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
      ),
      autoDismissDuration: _duration,
    );
  }

  /// 4. Dismisses the currently visible dialog overlay
  static void hide() {
    final currentContext = context;
    if (currentContext != null) {
      _isDialogOpen = false;
      Navigator.of(currentContext, rootNavigator: true).pop();
    }
  }
}
