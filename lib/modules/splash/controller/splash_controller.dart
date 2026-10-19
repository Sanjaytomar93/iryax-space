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
      const Duration(milliseconds: 700),
    );

    if (StorageService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
      return;
    }

    if (StorageService.registrationInProgress) {
      Get.offAllNamed(AppRoutes.registration);
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }
}