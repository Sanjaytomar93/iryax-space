import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/modules/navigation/controller/navigation_controller.dart';
import 'package:iryax_spaces/modules/notifications/controller/notification_controller.dart';
import 'package:iryax_spaces/modules/notifications/model/notification_model.dart';

class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  static const _navy = Color(0xFF26204A);
  static const _purple = Color(0xFF7B2CF5);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          _Header(
            top: top,
            onBack: Get.back,
            onMarkAll: () {
              if (controller.items.any((e) => !e.isRead)) {
                controller.markAllRead();
              }
            },
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return const NotificationListShimmer();
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.items.isEmpty) {
                return _Empty(
                  icon: Icons.cloud_off_outlined,
                  title: 'Couldn’t load',
                  subtitle: 'Pull to retry or tap below.',
                  action: 'Retry',
                  onAction: controller.loadNotifications,
                );
              }

              return Column(
                children: [
                  _Filters(controller: controller),
                  Expanded(
                    child: RefreshIndicator(
                      color: _purple,
                      onRefresh: controller.loadNotifications,
                      child: controller.filteredItems.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 80),
                                _Empty(
                                  icon: Icons.notifications_none_rounded,
                                  title: 'No notifications',
                                  subtitle:
                                      'Booking updates and offers will show here.',
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                              itemCount: controller.filteredItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final item = controller.filteredItems[i];
                                return _Tile(
                                  item: item,
                                  onTap: () => _onNotificationTap(item),
                                  onDelete: () =>
                                      controller.deleteNotification(item.id),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(NotificationModel item) {
    controller.markAsRead(item);

    if (item.type == 'bookings') {
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().changeTab(2);
      }
      Get.until((r) => r.settings.name == AppRoutes.dashboard);
      return;
    }

    if (item.type == 'offers') {
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().changeTab(1);
      }
      Get.until((r) => r.settings.name == AppRoutes.dashboard);
      return;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.top,
    required this.onBack,
    required this.onMarkAll,
  });

  final double top;
  final VoidCallback onBack;
  final VoidCallback onMarkAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, top + 10, 14, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDF3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: NotificationsView._navy,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: NotificationsView._navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Updates, offers & alerts',
                  style: TextStyle(
                    color: Color(0xFF8A8A99),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final c = Get.find<NotificationController>();
            // Touch items so Obx rebuilds after mark-read.
            final unread = c.items.where((e) => !e.isRead).length;
            if (unread == 0) return const SizedBox.shrink();
            return GestureDetector(
              onTap: onMarkAll,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: NotificationsView._purple,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Get.toNamed(AppRoutes.wishlist);
            },
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
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});

  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Row(
          children: NotificationFilter.values.map((f) {
            final on = selected == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.setFilter(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: on ? NotificationsView._navy : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: on ? NotificationsView._navy : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    '${_label(f)} (${controller.countFor(f)})',
                    style: TextStyle(
                      color: on ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  String _label(NotificationFilter f) {
    switch (f) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.bookings:
        return 'Bookings';
      case NotificationFilter.offers:
        return 'Offers';
      case NotificationFilter.system:
        return 'System';
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final v = _style(item);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: AppColors.softRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.dashboardRed,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.isRead
                    ? AppColors.lightBorder
                    : NotificationsView._purple.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: v.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(v.icon, color: v.fg, size: 22),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.lightTextPrimary,
                                fontSize: 14,
                                fontWeight: item.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            _ago(item.createdAt),
                            style: const TextStyle(
                              color: AppColors.lightHint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (item.message.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!item.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: NotificationsView._purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _V _style(NotificationModel item) {
    final t = item.title.toLowerCase();
    if (t.contains('payment') || t.contains('paid')) {
      return const _V(
        Icons.account_balance_wallet_outlined,
        AppColors.softGreen,
        AppColors.dashboardGreen,
      );
    }
    if (item.type == 'offers' || t.contains('offer')) {
      return const _V(
        Icons.local_offer_outlined,
        AppColors.softRed,
        AppColors.dashboardRed,
      );
    }
    if (item.type == 'bookings' ||
        t.contains('booking') ||
        t.contains('visit')) {
      return const _V(
        Icons.calendar_month_outlined,
        AppColors.softPurple,
        NotificationsView._purple,
      );
    }
    return const _V(
      Icons.info_outline_rounded,
      AppColors.softBlue,
      AppColors.dashboardBlue,
    );
  }

  String _ago(DateTime? d) {
    if (d == null) return '';
    final x = DateTime.now().difference(d);
    if (x.inMinutes < 1) return 'Just now';
    if (x.inMinutes < 60) return '${x.inMinutes} min ago';
    if (x.inHours < 24) return '${x.inHours}h ago';
    if (x.inDays == 1) return '1 day ago';
    if (x.inDays < 7) return '${x.inDays} days ago';
    return '${d.day}/${d.month}';
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.softPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: NotificationsView._purple),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            if (action != null && onAction != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onAction,
                child: Text(
                  action!,
                  style: const TextStyle(
                    color: NotificationsView._purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _V {
  const _V(this.icon, this.bg, this.fg);
  final IconData icon;
  final Color bg;
  final Color fg;
}
