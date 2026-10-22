import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/core/widgets/iryax_logo.dart';
import 'package:iryax_spaces/modules/bookings/view/my_bookings_view.dart';
import 'package:iryax_spaces/modules/dashboard(home)/view/dashboard_view.dart';
import 'package:iryax_spaces/modules/profile/view/profile_view.dart';
import 'package:iryax_spaces/modules/spaces/view/spaces_view.dart';
import 'package:iryax_spaces/modules/wishlist/view/wishlist_view.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../controller/navigation_controller.dart';

class MainNavigationView extends GetView<NavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.lightBackground,

        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 58,
          titleSpacing: 14,

          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: const IryaxLogoInline(size: 34),
              ),

              // PopupMenuButton<String>(
              //   tooltip: '',
              //   offset: const Offset(0, 42),
              //   color: AppColors.lightSurface,
              //   surfaceTintColor: Colors.transparent,
              //   elevation: 6,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   onSelected: (value) async {
              //     switch (value) {
              //       // case 'profile':
              //       //   controller.isProfileOpen.value = true;
              //       //   break;
              //
              //       case 'logout':
              //         _showLogoutDialog();
              //         break;
              //     }
              //   },
              //   itemBuilder: (context) => [
              //     // const PopupMenuItem<String>(
              //     //   value: 'profile',
              //     //   child: Row(
              //     //     children: [
              //     //       Icon(
              //     //         Icons.person_outline_rounded,
              //     //         color: AppColors.lightPrimary,
              //     //         size: 19,
              //     //       ),
              //     //       SizedBox(width: 10),
              //     //       Text(
              //     //         'Profile',
              //     //         style: TextStyle(
              //     //           color: AppColors.lightTextPrimary,
              //     //           fontSize: 13,
              //     //           fontWeight: FontWeight.w600,
              //     //         ),
              //     //       ),
              //     //     ],
              //     //   ),
              //     // ),
              //     // const PopupMenuDivider(),
              //     const PopupMenuItem<String>(
              //       value: 'logout',
              //       child: Row(
              //         children: [
              //           Icon(
              //             Icons.logout_rounded,
              //             color: AppColors.dashboardRed,
              //             size: 19,
              //           ),
              //           SizedBox(width: 10),
              //           Text(
              //             'Logout',
              //             style: TextStyle(
              //               color: AppColors.dashboardRed,
              //               fontSize: 13,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              //   child: Container(
              //     width: 34,
              //     height: 34,
              //     alignment: Alignment.center,
              //     decoration: BoxDecoration(
              //       color: AppColors.softPurple,
              //       borderRadius: BorderRadius.circular(9),
              //     ),
              //     child: const Icon(
              //       Icons.menu_rounded,
              //       color: AppColors.lightPrimary,
              //       size: 21,
              //     ),
              //   ),
              // ),
              // Container(
              //   width: 34,
              //   height: 34,
              //   decoration: BoxDecoration(
              //     color: AppColors.softPurple,
              //     borderRadius: BorderRadius.circular(9),
              //   ),
              //   child: const Icon(
              //     Icons.menu_rounded,
              //     color: AppColors.lightPrimary,
              //     size: 21,
              //   ),
              // ),
              const SizedBox(width: 8),

              const Text(
                'IRYAX SPACE',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.27,
                ),
              ),
            ],
          ),

          actions: [
            GestureDetector(
              onTap: () {
                controller.changeTab(2);
              },
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

            const SizedBox(width: 10),

            GestureDetector(
              onTap: controller.toggleProfile,
              // onTap: () {
              //   if (Get.currentRoute == AppRoutes.profile) {
              //     Get.back();
              //   } else {
              //     Get.toNamed(
              //       AppRoutes.profile,
              //     );
              //   }
              // },
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 14),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightPrimary,
                ),
                child: Text(
                  _getInitials(StorageService.userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.lightBorder),
          ),
        ),

        body:
            controller.isProfileOpen.value
                ? const ProfileView(embedded: true)
                : IndexedStack(
                  index: controller.selectedIndex.value,
                  children: const [
                    DashboardView(),
                    SpacesView(),
                    WishlistView(),
                    MyBookingsView(),
                  ],
                ),

        // body: IndexedStack(
        //   index: controller.selectedIndex.value,
        //   children: const [
        //     DashboardView(),
        //
        //     SpacesView(),
        //
        //     WishlistView(),
        //
        //     MyBookingsView(),
        //   ],
        // ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.bottomNavBackground,
            border: Border(
              top: BorderSide(color: AppColors.lightBorder, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 68,
                backgroundColor: AppColors.bottomNavBackground,
                indicatorColor: AppColors.softPurple,
                elevation: 0,
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                  states,
                ) {
                  final isSelected = states.contains(WidgetState.selected);

                  return TextStyle(
                    color:
                        isSelected
                            ? AppColors.bottomNavSelected
                            : AppColors.bottomNavUnselected,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
                  states,
                ) {
                  final isSelected = states.contains(WidgetState.selected);

                  return IconThemeData(
                    color:
                        isSelected
                            ? AppColors.bottomNavSelected
                            : AppColors.bottomNavUnselected,
                    size: 21,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: controller.changeTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard',
                  ),

                  NavigationDestination(
                    icon: Icon(Icons.home_work_outlined),
                    selectedIcon: Icon(Icons.home_work_rounded),
                    label: 'Spaces',
                  ),

                  NavigationDestination(
                    icon: Icon(Icons.favorite_border_rounded),
                    selectedIcon: Icon(Icons.favorite_rounded),
                    label: 'Wishlist',
                  ),

                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month_rounded),
                    label: 'My Bookings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.dashboardRed, size: 22),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.logout();

              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dashboardRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  String _getInitials(String name) {
    final value = name.trim();

    if (value.isEmpty) {
      return 'U';
    }

    final parts =
        value.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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
