import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();

    _handleStartup();
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _go(String route) {
    _hideKeyboard();
    Get.offAllNamed(route);
    // New route TextFields can steal focus after first frame — dismiss again.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hideKeyboard();
      Future<void>.delayed(const Duration(milliseconds: 150), _hideKeyboard);
      Future<void>.delayed(const Duration(milliseconds: 450), _hideKeyboard);
    });
  }

  Future<void> _handleStartup() async {
    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    _hideKeyboard();

    // Require both flag + token so a restored/partial session can't skip login.
    final hasValidSession =
        StorageService.isLoggedIn && StorageService.token.isNotEmpty;

    if (hasValidSession) {
      _go(AppRoutes.dashboard);
      return;
    }

    // Stale / restored session without a token — wipe and go to login.
    if (StorageService.isLoggedIn || StorageService.token.isNotEmpty) {
      await StorageService.clearAll();
    }

    if (StorageService.registrationInProgress) {
      _go(AppRoutes.registration);
      return;
    }

    _go(AppRoutes.login);
  }
}
