import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/modules/navigation/controller/navigation_controller.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/profile/controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  NavigationController get navigationController =>
      Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    final profileBody = Obx(
          () {
            if (controller.isLoading.value &&
                controller.profile.value.id.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color:
                  AppColors.lightPrimary,
                ),
              );
            }

            if (controller.errorMessage.value !=
                null &&
                controller.profile.value.id.isEmpty) {
              return Center(
                child: Padding(
                  padding:
                  const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color:
                        AppColors.dashboardRed,
                        size: 36,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        controller
                            .errorMessage.value ??
                            'Unable to load profile.',
                        textAlign:
                        TextAlign.center,
                        style: const TextStyle(
                          color: AppColors
                              .lightTextSecondary,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        onPressed:
                        controller.loadProfile,
                        child:
                        const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

        final data = controller.profile.value;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            30,
          ),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Profile',
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'View your profile information',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: controller.openEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _profileCompletionCard(),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientBlueStart,
                          AppColors.gradientPurpleEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _showLogoutDialog,
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withValues(
                          //     alpha: 0.16,
                          //   ),
                          //   borderRadius:
                          //   BorderRadius.circular(9),
                          //   border: Border.all(
                          //     color: Colors.white.withValues(
                          //       alpha: 0.40,
                          //     ),
                          //   ),
                          // ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: AppColors.dashboardRed,
                                size: 17,
                                weight: 900,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: AppColors.dashboardRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   height: 58,
                  //   decoration: const BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [
                  //         AppColors.gradientBlueStart,
                  //         AppColors.gradientPurpleEnd,
                  //       ],
                  //     ),
                  //     borderRadius: BorderRadius.vertical(
                  //       top: Radius.circular(18),
                  //     ),
                  //   ),
                  // ),

                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Text(
                              controller.initials,
                              style: const TextStyle(
                                color: AppColors.lightPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            data.name,
                            style: const TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                color: AppColors.lightTextSecondary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          const Divider(
                            color: AppColors.lightBorder,
                          ),

                          const SizedBox(height: 10),

                          _sectionTitle(
                            icon: Icons.person_outline,
                            title: 'PERSONAL INFORMATION',
                            color: AppColors.lightPrimary,
                          ),

                          const SizedBox(height: 12),

                          _detailTile(
                            icon: Icons.person_outline,
                            label: 'FULL NAME',
                            value: data.name,
                            iconBg: AppColors.softPurple,
                            iconColor: AppColors.lightPrimary,
                          ),

                          _detailTile(
                            icon: Icons.email_outlined,
                            label: 'EMAIL',
                            value: data.email,
                            iconBg: AppColors.softBlue,
                            iconColor: AppColors.dashboardBlue,
                          ),

                          _detailTile(
                            icon: Icons.phone_outlined,
                            label: 'MOBILE',
                            value: data.mobile,
                            iconBg: AppColors.softGreen,
                            iconColor: AppColors.dashboardGreen,
                          ),

                          _detailTile(
                            icon: Icons.location_on_outlined,
                            label: 'ADDRESS',
                            value: data.address,
                            iconBg: AppColors.softOrange,
                            iconColor: AppColors.dashboardOrange,
                          ),

                          _detailTile(
                            icon: Icons.calendar_month_outlined,
                            label: 'MEMBER SINCE',
                            value: data.memberSince,
                            iconBg: AppColors.softPurple,
                            iconColor: AppColors.lightPurple,
                          ),

                          _detailTile(
                            icon: Icons.person_outline,
                            label: 'ROLE',
                            value: data.role,
                            iconBg: AppColors.softPurple,
                            iconColor: AppColors.lightPrimary,
                            valueColor: AppColors.lightPrimary,
                          ),

                          const Divider(
                            color: AppColors.lightBorder,
                          ),

                          const SizedBox(height: 10),

                          _sectionTitle(
                            icon: Icons.home_work_outlined,
                            title: 'ORGANIZATION DETAILS',
                            color: AppColors.dashboardOrange,
                          ),

                          const SizedBox(height: 12),

                          _detailTile(
                            icon: Icons.home_work_outlined,
                            label: 'ORGANIZATION',
                            value: data.organization,
                            iconBg: AppColors.softOrange,
                            iconColor: AppColors.dashboardOrange,
                          ),

                          _detailTile(
                            icon: Icons.shield_outlined,
                            label: 'GST NUMBER',
                            value: data.gstNumber,
                            iconBg: AppColors.softOrange,
                            iconColor: AppColors.dashboardOrange,
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    navigationController.changeTab(3);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize:
                                    const Size.fromHeight(40),
                                    side: const BorderSide(
                                      color: AppColors.lightBorder,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.lightPrimary,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'My Bookings',
                                    style: TextStyle(
                                      color: AppColors.lightPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    navigationController.changeTab(1);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize:
                                    const Size.fromHeight(40),
                                    backgroundColor:
                                    AppColors.softGreen,
                                    side: const BorderSide(
                                      color: AppColors.lightBorder,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.shield_outlined,
                                    color: AppColors.dashboardGreen,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Browse Spaces',
                                    style: TextStyle(
                                      color: AppColors.dashboardGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Center(
              child: Text(
                '© IRYAX SPACE — All Rights Reserved',
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        );
      },
    );

    if (embedded) {
      return ColoredBox(
        color: AppColors.lightBackground,
        child: profileBody,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildProfileAppBar(),
      body: profileBody,
    );
  }


  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor:
        AppColors.lightSurface,
        surfaceTintColor:
        Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color:
              AppColors.dashboardRed,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                color: AppColors
                    .lightTextPrimary,
                fontSize: 17,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color:
            AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors
                    .lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed:
            controller.logout,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              AppColors.dashboardRed,
              foregroundColor:
              Colors.white,
              elevation: 0,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  9,
                ),
              ),
            ),
            icon: const Icon(
              Icons.logout_rounded,
              size: 15,
            ),
            label: const Text(
              'Logout',
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }



  PreferredSizeWidget _buildProfileAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBarBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 58,
      titleSpacing: 14,

      title: Row(
        children: [
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

          const SizedBox(width: 15),

          const Text(
            'IRYAX SPACE',
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),

      actions: [
        GestureDetector(
          onTap: () {
            navigationController.changeTab(2);

            if (Get.currentRoute.isNotEmpty &&
                Get.currentRoute != '/') {
              Get.back();
            }
          },
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.lightBorder,
              ),
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
          onTap: () {
            if (Get.key.currentState?.canPop() ?? false) {
              Get.back();
            }
          },
          child: Obx(
                () => Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(
                right: 14,
              ),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightPrimary,
              ),
              child: Text(
                controller.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.lightBorder,
        ),
      ),
    );
  }

  Widget _profileCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.profileCardStart,
            AppColors.profileCardEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.dashboardGreen,
                    width: 2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '100%',
                      style: TextStyle(
                        color: AppColors.dashboardGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'COMPLETE',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎉 Profile Completion',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _pill(
                          'Completed: ',
                          '100%',
                          AppColors.dashboardGreen,
                        ),
                        _pill(
                          'Pending: ',
                          '0',
                          AppColors.dashboardOrange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.softGreen,
              ),
            ),
            child: const Text(
              '✓  Your profile is 100% complete! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.dashboardGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(
      String prefix,
      String value,
      Color valueColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.lightTextSecondary,
          ),
          children: [
            TextSpan(
              text: prefix,
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 17,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 17,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                    valueColor ??
                        AppColors.lightTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.dashboardGreen,
            size: 17,
          ),
        ],
      ),
    );
  }
}