import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/core/widgets/notification_bell_button.dart';
import 'package:iryax_spaces/modules/bookings/view/my_bookings_view.dart';
import 'package:iryax_spaces/modules/dashboard(home)/view/dashboard_view.dart';
import 'package:iryax_spaces/modules/profile/view/profile_view.dart';
import 'package:iryax_spaces/modules/spaces/view/spaces_view.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../controller/navigation_controller.dart';

class MainNavigationView extends GetView<NavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canExit = !controller.isProfileOpen.value &&
          controller.selectedIndex.value == 0;

      return PopScope(
        canPop: canExit,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (controller.isProfileOpen.value) {
            controller.closeProfile();
            return;
          }
          if (controller.selectedIndex.value != 0) {
            controller.changeTab(0);
          }
        },
        child: Scaffold(
        backgroundColor: AppColors.lightBackground,

        appBar: _buildMainAppBar(),

        body:
            controller.isProfileOpen.value
                ? const ProfileView(embedded: true)
                : IndexedStack(
                  index: controller.selectedIndex.value,
                  children: [
                    ExcludeFocus(
                      excluding: controller.selectedIndex.value != 0,
                      child: const DashboardView(),
                    ),
                    ExcludeFocus(
                      excluding: controller.selectedIndex.value != 1,
                      child: const SpacesView(),
                    ),
                    ExcludeFocus(
                      excluding: controller.selectedIndex.value != 2,
                      child: const MyBookingsView(),
                    ),
                  ],
                ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.bottomNavBackground,
            border: Border(
              top: BorderSide(color: AppColors.lightBorder, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 54,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: 'Home',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.home_work_outlined,
                      selectedIcon: Icons.home_work_rounded,
                      label: 'Spaces',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.calendar_month_outlined,
                      selectedIcon: Icons.calendar_month_rounded,
                      label: 'My Bookings',
                    ),
                    _buildProfileNavItem(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      );
    });
  }

  PreferredSizeWidget _buildMainAppBar() {
    final onSpaces = !controller.isProfileOpen.value &&
        controller.selectedIndex.value == 1;

    return AppBar(
      backgroundColor:
          onSpaces ? const Color(0xFF26204A) : AppColors.appBarBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 58,
      titleSpacing: 20,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            onSpaces ? Brightness.light : Brightness.dark,
        statusBarBrightness: onSpaces ? Brightness.dark : Brightness.light,
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onSpaces
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.softPurple,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: onSpaces
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.lightBorder,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/iryax_logo.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'IRYAX SPACE',
            style: TextStyle(
              color: onSpaces ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.27,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: controller.openWishlist,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onSpaces
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: onSpaces
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.lightBorder,
              ),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              color: onSpaces
                  ? const Color(0xFFFF8A8A)
                  : AppColors.dashboardRed,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        NotificationBellButton(
          onTap: _openNotifications,
          onDark: onSpaces,
          margin: const EdgeInsets.only(right: 16),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: onSpaces
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.lightBorder,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected =
        !controller.isProfileOpen.value &&
        controller.selectedIndex.value == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.changeTab(index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.softPurple
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.bottomNavSelected
                      : AppColors.bottomNavUnselected,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.bottomNavSelected
                      : AppColors.bottomNavUnselected,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    final isSelected = controller.isProfileOpen.value;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.openProfile,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.softPurple
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  size: 24,
                  color: isSelected
                      ? AppColors.bottomNavSelected
                      : AppColors.bottomNavUnselected,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Profile',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.bottomNavSelected
                      : AppColors.bottomNavUnselected,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNotifications() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(AppRoutes.notifications);
  }
}

// class _PlaceholderView extends StatelessWidget {
//   final String title;
//   final IconData icon;
//
//   const _PlaceholderView({
//     required this.title,
//     required this.icon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ColoredBox(
//       color: AppColors.lightBackground,
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 62,
//               height: 62,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: AppColors.softPurple,
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Icon(
//                 icon,
//                 size: 30,
//                 color: AppColors.lightPrimary,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: AppColors.lightTextPrimary,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 5),
//             const Text(
//               'Coming soon',
//               style: TextStyle(
//                 color: AppColors.lightTextSecondary,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
// }
