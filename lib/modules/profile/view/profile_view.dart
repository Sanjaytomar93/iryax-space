import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/core/widgets/detail_nav_bar.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/navigation/controller/navigation_controller.dart';
import 'package:iryax_spaces/modules/profile/controller/profile_controller.dart';
import 'package:iryax_spaces/modules/wishlist/controller/wishlist_controller.dart';

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
    final profileBody = Obx(() {
      // 1. Loading State
      if (controller.isLoading.value && controller.profile.value.id.isEmpty) {
        return const ProfileShimmer();
      }

      // 2. Error State
      if (controller.errorMessage.value != null &&
          controller.profile.value.id.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.softRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.dashboardRed,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Could Not Load Profile',
                  style: TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.errorMessage.value ?? 'Unable to load profile data.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: controller.loadProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final data = controller.profile.value;

      return RefreshIndicator(
        color: AppColors.lightPrimary,
        backgroundColor: Colors.white,
        onRefresh: controller.loadProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          children: [
            // Direct Hero Profile Identity Card
            _buildHeroProfileCard(context, data),

            const SizedBox(height: 16),

            // Profile Completion Card
            _buildCompletionCard(),

            const SizedBox(height: 16),

            // Personal Information Card
            _buildPersonalDetailsCard(context, data),

            const SizedBox(height: 16),

            // Organization & Business Card
            _buildOrganizationCard(context, data),

            const SizedBox(height: 16),

            // Quick Navigation Shortcuts
            _buildQuickServicesCard(),

            const SizedBox(height: 16),

            // Logout & Account Action
            _buildAccountActionsCard(),

            const SizedBox(height: 24),

            // Footer
            _buildFooterBranding(),
          ],
        ),
      );
    });

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

  // ─────────────────────────────────────────────────────────
  // Frosted Refresh Button
  // ─────────────────────────────────────────────────────────
  Widget _buildFrostedRefreshButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
          ),
        ),
        child: IconButton(
          tooltip: 'Refresh Profile',
          onPressed: isLoading ? null : controller.loadProfile,
          padding: EdgeInsets.zero,
          icon: isLoading
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  size: 19,
                  color: Colors.white,
                ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────
  // Hero Identity Showcase Card
  // ─────────────────────────────────────────────────────────
  Widget _buildHeroProfileCard(BuildContext context, dynamic data) {
    final String name = data.name.isNotEmpty ? data.name : 'Valued Member';
    final String email = data.email.isNotEmpty ? data.email : 'No email provided';
    final String role = data.role.isNotEmpty ? data.role : 'Member';
    final bool isDoctor = data.isDoctor == true;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF26204A),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Same glow as attendance / dashboard profile card
          Positioned(
            right: -70,
            top: -90,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4F4780).withValues(alpha: 0.95),
                      const Color(0xFF3D3568).withValues(alpha: 0.45),
                      const Color(0xFF26204A).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: -30,
            child: IgnorePointer(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF5C548C).withValues(alpha: 0.35),
                      const Color(0xFF26204A).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              children: [
                // Avatar + User Details Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dual-Ring Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.35),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF26204A).withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              controller.initials,
                              style: const TextStyle(
                                color: AppColors.lightPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        // Verified / Doctor Icon Badge
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isDoctor
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF26204A).withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isDoctor
                                  ? Icons.local_hospital_rounded
                                  : Icons.check_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // User Names & Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.alternate_email_rounded,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Role Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  isDoctor ? '🩺 Doctor / Specialist' : role,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              // Verified Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified_user_rounded,
                                      size: 11,
                                      color: Color(0xFF6EE7B7),
                                    ),
                                    const SizedBox(width: 3.5),
                                    const Text(
                                      'Verified Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFrostedRefreshButton(),
                  ],
                ),

                const SizedBox(height: 16),

                // Interactive Quick Stats Strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Bookings Metric
                      Expanded(
                        child: _buildHeroStatItem(
                          label: 'Bookings',
                          icon: Icons.calendar_month_rounded,
                          value: _getBookingsCountText(),
                          onTap: () => navigationController.changeTab(2),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      // Wishlist Metric
                      Expanded(
                        child: _buildHeroStatItem(
                          label: 'Wishlist',
                          icon: Icons.favorite_rounded,
                          value: _getWishlistCountText(),
                          onTap: navigationController.openWishlist,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      // Completion Metric
                      Expanded(
                        child: _buildHeroStatItem(
                          label: 'Profile',
                          icon: Icons.pie_chart_outline_rounded,
                          value: '${controller.completionPercent}%',
                          onTap: controller.openEditProfile,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatItem({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBookingsCountText() {
    if (Get.isRegistered<BookingsController>()) {
      final bc = Get.find<BookingsController>();
      final total = bc.bookings.length + bc.siteVisits.length;
      return total > 0 ? '$total' : 'View';
    }
    return 'View';
  }

  String _getWishlistCountText() {
    if (Get.isRegistered<WishlistController>()) {
      final wc = Get.find<WishlistController>();
      final count = wc.totalSaved;
      return count > 0 ? '$count' : 'View';
    }
    return 'View';
  }

  // ─────────────────────────────────────────────────────────
  // Dynamic Profile Completion Card
  // ─────────────────────────────────────────────────────────
  Widget _buildCompletionCard() {
    final int percent = controller.completionPercent;
    final bool is100 = percent >= 100;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: is100
              ? AppColors.dashboardGreen.withValues(alpha: 0.3)
              : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Percent Gauge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: is100 ? AppColors.softGreen : AppColors.softPurple,
                  border: Border.all(
                    color: is100
                        ? AppColors.dashboardGreen
                        : AppColors.lightPrimary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$percent%',
                    style: TextStyle(
                      color: is100
                          ? AppColors.dashboardGreen
                          : AppColors.lightPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          is100
                              ? 'Profile Fully Complete'
                              : 'Profile Setup: $percent%',
                          style: const TextStyle(
                            color: AppColors.lightTextPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          is100 ? '🎉' : '⚡',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      is100
                          ? 'Your account has all required information.'
                          : controller.pendingFields.isNotEmpty
                              ? 'Missing: ${controller.pendingFields.join(', ')}'
                              : 'Complete details to unlock express booking.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              if (!is100)
                TextButton(
                  onPressed: controller.openEditProfile,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.lightPrimary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    'Complete',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent / 100.0,
              minHeight: 6,
              backgroundColor: AppColors.lightBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                is100 ? AppColors.dashboardGreen : AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Personal Details Section Card
  // ─────────────────────────────────────────────────────────
  Widget _buildPersonalDetailsCard(BuildContext context, dynamic data) {
    return _buildContentContainer(
      title: 'Personal Information',
      subtitle: 'Your personal identification details',
      icon: Icons.person_outline_rounded,
      iconColor: AppColors.lightPrimary,
      iconBg: AppColors.softPurple,
      onEdit: controller.openEditProfile,
      children: [
        _buildInfoRow(
          icon: Icons.badge_outlined,
          iconBg: AppColors.softPurple,
          iconColor: AppColors.lightPrimary,
          label: 'FULL NAME',
          value: data.name.isNotEmpty ? data.name : '—',
        ),
        _buildInfoRow(
          icon: Icons.alternate_email_rounded,
          iconBg: AppColors.softBlue,
          iconColor: AppColors.dashboardBlue,
          label: 'EMAIL ADDRESS',
          value: data.email.isNotEmpty ? data.email : '—',
          copyable: data.email.isNotEmpty,
        ),
        _buildInfoRow(
          icon: Icons.phone_iphone_rounded,
          iconBg: AppColors.softGreen,
          iconColor: AppColors.dashboardGreen,
          label: 'MOBILE NUMBER',
          value: data.mobile.isNotEmpty ? data.mobile : '—',
          copyable: data.mobile.isNotEmpty,
        ),
        _buildInfoRow(
          icon: Icons.location_on_outlined,
          iconBg: AppColors.softOrange,
          iconColor: AppColors.dashboardOrange,
          label: 'ADDRESS',
          value: data.address.isNotEmpty ? data.address : 'Not specified',
        ),
        _buildInfoRow(
          icon: Icons.event_available_rounded,
          iconBg: AppColors.softPurple,
          iconColor: AppColors.lightPurple,
          label: 'MEMBER SINCE',
          value: data.memberSince.isNotEmpty ? data.memberSince : '—',
          isLast: true,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // Organization Details Section Card
  // ─────────────────────────────────────────────────────────
  Widget _buildOrganizationCard(BuildContext context, dynamic data) {
    final bool hasOrg = data.organization.isNotEmpty;
    final bool hasGst = data.gstNumber.isNotEmpty;

    return _buildContentContainer(
      title: 'Organization & Tax',
      subtitle: 'Clinic, enterprise, and invoicing details',
      icon: Icons.apartment_rounded,
      iconColor: AppColors.dashboardOrange,
      iconBg: AppColors.softOrange,
      onEdit: controller.openEditProfile,
      children: [
        _buildInfoRow(
          icon: Icons.business_rounded,
          iconBg: AppColors.softOrange,
          iconColor: AppColors.dashboardOrange,
          label: 'ORGANIZATION / CLINIC',
          value: hasOrg ? data.organization : 'Not specified',
          valueColor: hasOrg ? null : AppColors.lightTextSecondary,
        ),
        _buildInfoRow(
          icon: Icons.receipt_long_rounded,
          iconBg: AppColors.softBlue,
          iconColor: AppColors.dashboardBlue,
          label: 'GST NUMBER',
          value: hasGst ? data.gstNumber : 'Not provided',
          copyable: hasGst,
          valueColor: hasGst ? null : AppColors.lightTextSecondary,
        ),
        _buildInfoRow(
          icon: data.isDoctor == true
              ? Icons.medical_services_outlined
              : Icons.workspace_premium_outlined,
          iconBg: AppColors.softGreen,
          iconColor: AppColors.dashboardGreen,
          label: 'ACCOUNT CATEGORY',
          value: data.isDoctor == true
              ? 'Medical Practitioner / Doctor'
              : (data.role.isNotEmpty ? data.role : 'Standard User'),
          isLast: true,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // Quick Navigation Services Card
  // ─────────────────────────────────────────────────────────
  Widget _buildQuickServicesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.explore_outlined,
                    size: 16,
                    color: AppColors.dashboardBlue,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Quick Shortcuts',
                  style: TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.lightBorder, height: 1),
          _buildQuickActionTile(
            icon: Icons.calendar_month_rounded,
            iconBg: AppColors.softPurple,
            iconColor: AppColors.lightPrimary,
            title: 'My Bookings & Visits',
            subtitle: 'Track reservations and scheduled visits',
            onTap: () => navigationController.changeTab(2),
          ),
          const Divider(
            color: AppColors.lightBorder,
            height: 1,
            indent: 56,
          ),
          _buildQuickActionTile(
            icon: Icons.favorite_rounded,
            iconBg: AppColors.softRed,
            iconColor: AppColors.dashboardRed,
            title: 'Saved Workspaces',
            subtitle: 'View your shortlisted medical and commercial spaces',
            onTap: navigationController.openWishlist,
          ),
          const Divider(
            color: AppColors.lightBorder,
            height: 1,
            indent: 56,
          ),
          _buildQuickActionTile(
            icon: Icons.travel_explore_rounded,
            iconBg: AppColors.softGreen,
            iconColor: AppColors.dashboardGreen,
            title: 'Explore Spaces',
            subtitle: 'Discover new clinics and medical offices',
            onTap: () => navigationController.changeTab(1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.lightHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Logout & Account Actions Card
  // ─────────────────────────────────────────────────────────
  Widget _buildAccountActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutDialog,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.softRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.dashboardRed,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: AppColors.dashboardRed,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Sign out of your active session on this device',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.dashboardRed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Reusable Container for Content Sections
  // ─────────────────────────────────────────────────────────
  Widget _buildContentContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Edit Details',
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.softPurple,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.lightPrimary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.lightBorder, height: 1),

          // Detail rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Reusable Info Row with Copy Capability
  // ─────────────────────────────────────────────────────────
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool copyable = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor ?? AppColors.lightTextPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              tooltip: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar(
                  'Copied to Clipboard',
                  '$value copied successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.lightTextPrimary.withValues(alpha: 0.9),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                  duration: const Duration(seconds: 2),
                  icon: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF6EE7B7),
                  ),
                );
              },
              icon: const Icon(
                Icons.copy_rounded,
                size: 15,
                color: AppColors.lightTextSecondary,
              ),
              splashRadius: 18,
              visualDensity: VisualDensity.compact,
            )
          else
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.dashboardGreen,
              size: 16,
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Footer Branding
  // ─────────────────────────────────────────────────────────
  Widget _buildFooterBranding() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.lightPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'IRYAX SPACES • Healthcare & Workspace Solutions',
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '© 2026 IRYAX All rights reserved • App Version 1.0.0',
          style: TextStyle(
            color: AppColors.lightHint,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // Logout Dialog
  // ─────────────────────────────────────────────────────────
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
        contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
        actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.softRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.dashboardRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Log Out',
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your IRYAX account on this device?',
          style: TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: Get.back,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.lightBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dashboardRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 15),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  // ─────────────────────────────────────────────────────────
  // Standalone Profile AppBar
  // ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildProfileAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DetailNavBar(
              title: 'My Profile',
              subtitle: 'Manage your account',
              onBack: () {
                if (Get.key.currentState?.canPop() ?? false) {
                  Get.back();
                }
              },
              onWishlist: () {
                if (Get.currentRoute.isNotEmpty && Get.currentRoute != '/') {
                  Get.back();
                }
                navigationController.openWishlist();
              },
            ),
            Container(height: 1, color: AppColors.lightBorder),
          ],
        ),
      ),
    );
  }
}
