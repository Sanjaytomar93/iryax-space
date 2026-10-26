import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../wishlist/controller/wishlist_controller.dart';

class NavigationController extends GetxController {
  final selectedIndex = 0.obs;
  final isProfileOpen = false.obs;

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void onReady() {
    super.onReady();
    // Home/Spaces/Bookings search fields mount with IndexedStack and can
    // steal focus on cold start / hot restart — force keyboard closed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hideKeyboard();
      Future<void>.delayed(const Duration(milliseconds: 120), _hideKeyboard);
      Future<void>.delayed(const Duration(milliseconds: 400), _hideKeyboard);
    });
  }

  void toggleProfile() {
    isProfileOpen.value = !isProfileOpen.value;
  }

  void openProfile() {
    _hideKeyboard();
    isProfileOpen.value = true;
  }

  void closeProfile() {
    isProfileOpen.value = false;
  }

  void changeTab(int index) {
    _hideKeyboard();
    isProfileOpen.value = false;
    selectedIndex.value = index;

    // Spaces = tab 1 — keep hearts / list in sync.
    if (index == 1 && Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().ensureLoaded();
    }
  }

  void openWishlist() {
    _hideKeyboard();
    isProfileOpen.value = false;
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().ensureLoaded();
    }
    Get.toNamed(AppRoutes.wishlist);
  }
}