import 'package:get/get.dart';

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
  }
}