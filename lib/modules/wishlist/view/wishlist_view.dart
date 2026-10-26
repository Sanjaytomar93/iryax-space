import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/core/widgets/notification_bell_button.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/spaces/widget/space_listing_card.dart';
import 'package:iryax_spaces/modules/wishlist/controller/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({
    super.key,
  });

  static const _navy = Color(0xFF26204A);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureLoaded();
    });

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 14),
                  Obx(() {
                    if (controller.isLoading.value &&
                        controller.items.isEmpty) {
                      return const SpaceListShimmer();
                    }

                    if (controller.errorMessage.value.isNotEmpty &&
                        controller.items.isEmpty) {
                      return _buildErrorState();
                    }

                    final items = controller.filteredItems;

                    if (controller.items.isEmpty) {
                      return _buildEmptyState();
                    }

                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 35),
                        child: Center(
                          child: Text(
                            'No wishlist items match your search.',
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildWishlistCard(item),
                            ),
                          )
                          .toList(),
                    );
                  }),
                  const SizedBox(height: 18),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F1A3D),
              Color(0xFF26204A),
              Color(0xFF3D3568),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -70,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE85B5B).withValues(alpha: 0.22),
                        const Color(0xFF3D3568).withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -30,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, top + 10, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _backButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Wishlist',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.totalSaved == 1
                                    ? '1 space saved'
                                    : '${controller.totalSaved} spaces saved',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NotificationBellButton(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Get.toNamed(AppRoutes.notifications);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF8A8A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your saved medical & commercial spaces',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: controller.searchController,
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search wishlist...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12.5,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 18,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: Get.back,
      behavior: HitTestBehavior.opaque,
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


  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.dashboardRed,
            size: 32,
          ),

          const SizedBox(height: 10),

          const Text(
            'Unable to load wishlist',
            style: TextStyle(
              color:
              AppColors.lightTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color:
              AppColors.lightTextSecondary,
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed:
              controller.loadWishlist,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.lightPrimary,
                foregroundColor:
                Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(
          () => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius:
          BorderRadius.circular(13),
          border: Border.all(
            color: AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26204A)
                  .withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _summaryItem(
                label: 'Total Saved',
                value:
                '${controller.totalSaved}',
              ),
            ),

            Container(
              width: 1,
              height: 34,
              color: AppColors.lightBorder,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 14,
                ),
                child: _summaryItem(
                  label: 'Categories',
                  value:
                  '${controller.totalCategories}',
                  valueColor:
                  AppColors.lightTextPrimary,
                ),
              ),
            ),

            const SizedBox(width: 8),

            InkWell(
              onTap: _confirmClearAll,
              borderRadius:
              BorderRadius.circular(9),
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softRed,
                  borderRadius:
                  BorderRadius.circular(9),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color:
                      AppColors.dashboardRed,
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Clear All',
                      style: TextStyle(
                        color:
                        AppColors.dashboardRed,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    if (controller.items.isEmpty) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text(
          'Remove all saved spaces from your wishlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.dashboardRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.clearAll();
    }
  }

  Widget _summaryItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color:
            AppColors.lightTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ??
                AppColors.lightPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistCard(SpaceModel item) {
    return SpaceListingCard(
      space: item,
      showSavedBadge: true,
      onDoubleTapLike: () => controller.removeItem(item.id),
      topRightAction: InkWell(
        onTap: () => controller.removeItem(item.id),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: AppColors.dashboardRed,
            size: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(
          color: AppColors.lightBorder,
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF26204A),
                borderRadius:
                BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 17,
              ),
            ),

            const SizedBox(width: 9),

            const Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'IRYAX SPACE',
                  style: TextStyle(
                    color: AppColors
                        .lightTextPrimary,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                Text(
                  'MY WISHLIST',
                  style: TextStyle(
                    color: AppColors
                        .lightTextSecondary,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              color:
              AppColors.dashboardGreen,
              size: 12,
            ),
            SizedBox(width: 4),
            Text(
              'Secure',
              style: TextStyle(
                color: AppColors
                    .lightTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 14),
            Icon(
              Icons.access_time_rounded,
              color:
              AppColors.dashboardGreen,
              size: 12,
            ),
            SizedBox(width: 4),
            Text(
              '24/7 Access',
              style: TextStyle(
                color: AppColors
                    .lightTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Text(
          '© 2026 IRYAX SPACE — All Rights Reserved',
          style: TextStyle(
            color:
            AppColors.lightTextSecondary,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 50,
      ),
      child: const Column(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color:
            AppColors.lightTextSecondary,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              color:
              AppColors.lightTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Save spaces you like and they will appear here.',
            style: TextStyle(
              color:
              AppColors.lightTextSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}