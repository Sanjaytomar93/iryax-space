import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/notifications/controller/notification_controller.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({
    super.key,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.onDark = false,
  });

  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? _open,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        margin: margin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onDark
              ? Colors.white.withValues(alpha: 0.15)
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onDark
                ? Colors.white.withValues(alpha: 0.25)
                : AppColors.lightBorder,
          ),
        ),
        child: Obx(() {
          final count = Get.isRegistered<NotificationController>()
              ? Get.find<NotificationController>()
                  .items
                  .where((e) => !e.isRead)
                  .length
              : 0;
          final label = count > 99 ? '99+' : '$count';

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: onDark ? Colors.white : AppColors.lightPrimary,
                size: 20,
              ),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B2CF5), Color(0xFF5B21B6)],
                      ),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B2CF5).withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _open() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(AppRoutes.notifications);
  }
}
