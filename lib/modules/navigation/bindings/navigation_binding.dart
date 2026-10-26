import 'package:get/get.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/dashboard(home)/controller/home_controller.dart';
import 'package:iryax_spaces/modules/notifications/controller/notification_controller.dart';
import 'package:iryax_spaces/modules/profile/controller/profile_controller.dart';

import '../../spaces/controller/spaces_controller.dart';
import '../../wishlist/controller/wishlist_controller.dart';
import '../controller/navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NavigationController>()) {
      Get.put<NavigationController>(
        NavigationController(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<SpacesController>()) {
      Get.put<SpacesController>(
        SpacesController(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<WishlistController>()) {
      Get.put<WishlistController>(
        WishlistController(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<BookingsController>()) {
      Get.put<BookingsController>(
        BookingsController(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<NotificationController>()) {
      Get.put<NotificationController>(
        NotificationController(),
        permanent: true,
      );
    }

    Get.lazyPut<HomeController>(
          () => HomeController(),
      fenix: true,
    );

    Get.lazyPut<ProfileController>(
          () => ProfileController(),
      fenix: true,
    );
  }
}