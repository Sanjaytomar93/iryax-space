import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/spaces/widget/space_listing_card.dart';
import 'package:iryax_spaces/modules/wishlist/controller/wishlist_controller.dart';

class SpacesView extends GetView<SpacesController> {
  const SpacesView({super.key});

  WishlistController get wishlistController => Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.lightBackground,
      child: RefreshIndicator(
        onRefresh: controller.refreshSpaces,
        child: Obx(() {
          final spaces = controller.filteredSpaces;
          final loading =
              controller.isLoading.value && controller.spaces.isEmpty;
          final error =
              controller.errorMessage.value != null &&
              controller.spaces.isEmpty;
          final empty = !loading && !error && spaces.isEmpty;
          final contentCount = loading || error || empty ? 1 : spaces.length;

          return ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: 2 + contentCount,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeroWithCategories();
              if (index == 1) {
                return KeyedSubtree(
                  key: controller.cardsSectionKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                    child: Column(
                      children: [
                        _buildAvailableHeader(),
                        const SizedBox(height: 7),
                        _buildSearchAndFilters(),
                      ],
                    ),
                  ),
                );
              }

              final cardIndex = index - 2;
              if (loading) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(14, 0, 14, 70),
                  child: SpaceListShimmer(),
                );
              }
              if (error) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 70),
                  child: _buildErrorState(),
                );
              }
              if (empty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 70),
                  child: _buildEmptyState(),
                );
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  cardIndex == spaces.length - 1 ? 95 : 12,
                ),
                child: _buildSpaceCard(spaces[cardIndex]),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
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
            'Unable to load spaces',
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Obx(
            () => Text(
              controller.errorMessage.value ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: controller.getSpaces,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = controller.searchQuery.value.trim().isNotEmpty;
    final hasCabinFilter =
        controller.selectedCabinType.value != 'All Cabin Types';
    final hasSortFilter = controller.selectedFilter.value != 'All' &&
        controller.selectedFilter.value != 'All Spaces';
    final category = controller.selectedCategory.value;
    final showReset = hasSearch ||
        hasCabinFilter ||
        hasSortFilter ||
        (category != 'All' && category != 'All Spaces');

    final String title;
    final String subtitle;
    final IconData icon;

    if (hasSearch) {
      title = 'No matching spaces';
      subtitle = 'Try a different search or clear filters.';
      icon = Icons.search_off_rounded;
    } else if (hasCabinFilter || hasSortFilter) {
      title = 'No spaces match filters';
      subtitle = 'Adjust filters to see more $category spaces.';
      icon = Icons.filter_alt_outlined;
    } else {
      title = 'No spaces found';
      subtitle = 'No active $category spaces right now.';
      icon = Icons.home_work_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.lightPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          if (showReset) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: controller.clearFilters,
              child: const Text(
                'Reset filters',
                style: TextStyle(
                  color: AppColors.lightPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroWithCategories() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(),
            const SizedBox(height: 178),
          ],
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 0,
          child: _buildCategories(),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 82),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.34, -0.94),
          end: Alignment(0.34, 0.94),
          colors: [Color(0xFF26204A), Color(0xFF3D3568), Color(0xFF4F4780)],
          stops: [0, 0.55, 1],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 27,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: Color(0xFFFFD84D)),
                SizedBox(width: 6),
                Text(
                  'IRYAX SPACES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 13 / 11,
                    letterSpacing: 0.33,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Column(
              children: [
                Text(
                  'Find Your Perfect',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 29 / 20,
                  ),
                ),
                Text(
                  'Workspace Today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFD84D),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 29 / 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 11),
            child: Text(
              'Discover premium co-working spaces, medical chambers, meeting rooms & private offices tailored to your professional needs',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12.9,
                fontWeight: FontWeight.w400,
                height: 20 / 12.9,
              ),
            ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 6),
                Icon(
                  Icons.search_rounded,
                  size: 15,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      autofocus: false,
                      controller: controller.searchController,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        controller.scrollToSpaceCards();
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Search for spaces...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    controller.scrollToSpaceCards();
                  },
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Explore',
                          style: TextStyle(
                            color: Color(0xFF4338CA),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: Color(0xFF4338CA),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final activeSpaces = controller.spaces.where(
              (space) => space.isActive,
            );
            final totalSeats = activeSpaces.fold<int>(
              0,
              (sum, item) => sum + item.seatCount,
            );

            return Row(
              children: [
                Expanded(
                  child: _heroStat(
                    icon: Icons.home_outlined,
                    value: '${activeSpaces.length}+',
                    label: 'SPACES',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _heroStat(
                    icon: Icons.groups_outlined,
                    value: '$totalSeats+',
                    label: 'SEATS',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _heroStat(
                    icon: Icons.star_border_rounded,
                    value: '4.8★',
                    label: 'RATING',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _heroStat(
                    icon: Icons.access_time_rounded,
                    value: '24/7',
                    label: 'ACCESS',
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: Colors.white, size: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 7.5,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF26204A), Color(0xFF3D3568)],
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.explore_outlined,
                  color: Colors.white,
                  size: 13,
                ),
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse Categories',
                      style: TextStyle(
                        color: Color(0xFF26204A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Find the perfect space for your needs',
                      style: TextStyle(
                        color: Color(0xFF8A8A99),
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final category = controller.selectedCategory.value;
                final showClear = category != 'All' &&
                    category != 'All Spaces';
                if (!showClear) return const SizedBox.shrink();

                return InkWell(
                  onTap: controller.clearFilters,
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFFE7E7F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 9,
                          color: Color(0xFF4338CA),
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Clear',
                          style: TextStyle(
                            color: Color(0xFF4338CA),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final selected = controller.selectedCategory.value;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _categoryCard(
                        title: 'Co-Working',
                        subtitle: 'Flexible workspaces',
                        count: '${controller.coworkingSpaces.length} Spaces',
                        icon: Icons.business_center_outlined,
                        selected: selected == 'Co-Working',
                        onTap: () =>
                            controller.changeCategory('Co-Working'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _categoryCard(
                        title: 'Meeting Rooms',
                        subtitle: 'Conference & events',
                        count: '${controller.meetingRooms.length} Rooms',
                        icon: Icons.groups_outlined,
                        selected: selected == 'Meeting Rooms',
                        onTap: () =>
                            controller.changeCategory('Meeting Rooms'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _categoryCard(
                        title: 'Medical Chambers',
                        subtitle: 'Healthcare spaces',
                        count: '${controller.medicalChambers.length} Chambers',
                        icon: Icons.medical_services_outlined,
                        selected: selected == 'Medical Chambers',
                        onTap: () =>
                            controller.changeCategory('Medical Chambers'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _categoryCard(
                        title: 'Private Offices',
                        subtitle: 'Dedicated spaces',
                        count: '${controller.privateOffices.length} Offices',
                        icon: Icons.lock_outline_rounded,
                        selected: selected == 'Private Offices',
                        onTap: () =>
                            controller.changeCategory('Private Offices'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _categoryCard(
                  title: 'Cafe & Dining',
                  subtitle: 'Cafes & dining tables',
                  count: '${controller.cafeAndDiningSpaces.length} Tables',
                  icon: Icons.restaurant_menu_rounded,
                  selected: selected == 'Cafe & Dining',
                  onTap: () => controller.changeCategory('Cafe & Dining'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required String title,
    required String subtitle,
    required String count,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: selected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF2F1F6), Color(0xFFE6E4EF)],
                      )
                    : null,
                color: selected ? null : Colors.white,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF26204A)
                      : const Color(0xFFE8E8F2),
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF26204A).withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF26204A).withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3D3568), Color(0xFF26204A)],
                            )
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF2F1F6), Color(0xFFE6E4EF)],
                            ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF26204A)
                                    .withValues(alpha: 0.28),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF26204A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF3B34A8)
                                : const Color(0xFF26204A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8A8A99),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF26204A).withValues(alpha: 0.12)
                                : const Color(0xFFF3F3F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            count,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF26204A)
                                  : const Color(0xFF6B6B7A),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selected)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF16A34A)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // AVAILABLE HEADER
  // ============================================================

  Widget _buildAvailableHeader() {
    return Obx(() {
      final count = controller.filteredSpaces.length;
      final category = controller.selectedCategory.value;

      return Row(
        children: [
          const Icon(
            Icons.radio_button_checked,
            color: AppColors.lightPrimary,
            size: 10,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Spaces Available',
                  style: const TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Showing $category spaces',
                  style: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '↝ $count results',
              style: const TextStyle(
                color: AppColors.dashboardGreen,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    });
  }

  // ============================================================
  // SEARCH / FILTER
  // ============================================================

  Widget _buildSearchAndFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C26204A),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26204A), Color(0xFF3D3568)],
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Obx(() {
                final hasFilter = controller.searchQuery.value.isNotEmpty ||
                    (controller.selectedCategory.value != 'All' &&
                        controller.selectedCategory.value != 'All Spaces') ||
                    controller.selectedCabinType.value != 'All Cabin Types' ||
                    (controller.selectedFilter.value != 'All' &&
                        controller.selectedFilter.value != 'All Spaces');

                if (!hasFilter) return const SizedBox.shrink();

                return InkWell(
                  onTap: controller.clearFilters,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F0FD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 11,
                          color: AppColors.lightPrimary,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Reset',
                          style: TextStyle(
                            color: AppColors.lightPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 33,
            child: TextField(
              autofocus: false,
              controller: controller.searchController,
              cursorColor: AppColors.lightPrimary,
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 10.5,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, address, or description...',
                hintStyle: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 9.5,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 14,
                  color: AppColors.lightTextSecondary,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 32),
                filled: true,
                fillColor: AppColors.lightBackground,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 7,
                  horizontal: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.lightPrimary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _dropdownBox(
                    value: controller.selectedCategory.value == 'All'
                        ? 'All Spaces'
                        : controller.selectedCategory.value,
                    items: const [
                      'All Spaces',
                      'Co-Working',
                      'Medical Chambers',
                      'Cafe & Dining',
                      'Private Offices',
                      'Meeting Rooms',
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeCategory(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _dropdownBox(
                    value: controller.selectedCabinType.value,
                    items: const ['All Cabin Types', 'Normal', 'Exclusive'],
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeCabinType(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _filterChip(
                    text: 'All Spaces',
                    icon: Icons.auto_awesome_rounded,
                    selected: controller.selectedFilter.value == 'All' ||
                        controller.selectedFilter.value == 'All Spaces',
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _filterChip(
                    text: 'Top Rated',
                    icon: Icons.workspace_premium_outlined,
                    selected: controller.selectedFilter.value == 'Top Rated',
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _filterChip(
                    text: 'New Added',
                    icon: Icons.auto_awesome_outlined,
                    selected: controller.selectedFilter.value == 'New Added',
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _filterChip(
                    text: 'Nearest',
                    icon: Icons.near_me_outlined,
                    selected: controller.selectedFilter.value == 'Nearest',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownBox({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.lightSurface,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 13,
            color: AppColors.lightTextSecondary,
          ),
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: 10,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _filterChip({
    required String text,
    required IconData icon,
    required bool selected,
  }) {
    return InkWell(
      onTap: () {
        controller.changeFilter(text);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 27,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightPrimary : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.lightPrimary : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 10,
              color: selected ? Colors.white : AppColors.lightTextPrimary,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.lightTextPrimary,
                  fontSize: 8.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SPACE CARD
  // ============================================================

  Widget _buildSpaceCard(SpaceModel space) {
    return SpaceListingCard(
      space: space,
      showFavoriteButton: true,
      onDoubleTapLike: () {
        // Double-tap should like (not unlike).
        if (!wishlistController.isFavorite(space.id)) {
          wishlistController.toggleFavorite(space);
        }
      },
    );
  }
}
