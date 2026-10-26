import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/widgets/notification_bell_button.dart';

class DetailNavBar extends StatelessWidget {
  const DetailNavBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.onWishlist,
    this.onNotification,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onWishlist;
  final VoidCallback? onNotification;
  final Widget? trailing;

  static const _navy = Color(0xFF26204A);
  static const _subtitle = Color(0xFF8A8A99);
  static const _backOuter = Color(0xFFEEEDF3);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 10, 16, 10),
      child: Row(
        children: [
          _backButton(onTap: onBack ?? Get.back),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _subtitle,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (trailing != null)
            trailing!
          else ...[
            _wishlistButton(),
            const SizedBox(width: 8),
            NotificationBellButton(onTap: onNotification ?? _openNotifications),
          ],
        ],
      ),
    );
  }

  Widget _backButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _backOuter,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _wishlistButton() {
    return GestureDetector(
      onTap: onWishlist ?? _openWishlist,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: const Icon(
          Icons.favorite_border_rounded,
          color: AppColors.dashboardRed,
          size: 20,
        ),
      ),
    );
  }

  void _openWishlist() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(AppRoutes.wishlist);
  }

  void _openNotifications() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(AppRoutes.notifications);
  }
}
