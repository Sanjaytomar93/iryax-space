import 'package:get/get.dart';

import '../../wishlist/controller/wishlist_controller.dart';

class NavigationController extends GetxController {
  final selectedIndex = 0.obs;
  final isProfileOpen = false.obs;

  void toggleProfile() {
    isProfileOpen.value = !isProfileOpen.value;
  }

  void closeProfile() {
    isProfileOpen.value = false;
  }

  void changeTab(int index) {
    isProfileOpen.value = false;
    selectedIndex.value = index;

    // Wishlist = tab 2, Spaces = tab 1 — keep hearts / list in sync.
    if ((index == 1 || index == 2) &&
        Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().ensureLoaded();
    }
  }
}