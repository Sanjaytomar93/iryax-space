import 'package:get/get.dart';

import 'package:iryax_spaces/modules/notifications/controller/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationController>()) {
      Get.put<NotificationController>(
        NotificationController(),
        permanent: true,
      );
    } else {
      Get.find<NotificationController>().refreshQuietly();
    }
  }
}
