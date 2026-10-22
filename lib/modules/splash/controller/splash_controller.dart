import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();

    _handleStartup();
  }

  Future<void> _handleStartup() async {
    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    // Require both flag + token so a restored/partial session can't skip login.
    final hasValidSession =
        StorageService.isLoggedIn && StorageService.token.isNotEmpty;

    if (hasValidSession) {
      Get.offAllNamed(AppRoutes.dashboard);
      return;
    }

    // Stale / restored session without a token — wipe and go to login.
    if (StorageService.isLoggedIn || StorageService.token.isNotEmpty) {
      await StorageService.clearAll();
    }

    if (StorageService.registrationInProgress) {
      Get.offAllNamed(AppRoutes.registration);
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }
}
