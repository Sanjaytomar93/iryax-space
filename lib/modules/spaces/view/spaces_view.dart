import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/wishlist/controller/wishlist_controller.dart';

class SpacesView extends GetView<SpacesController> {
  const SpacesView({
    super.key,
  });

  WishlistController get wishlistController =>
      Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.lightBackground,
      child: RefreshIndicator(
        onRefresh: controller.refreshSpaces,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _buildHero(),

            Transform.translate(
              offset: const Offset(0, -18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Column(
                  children: [
                    _buildCategories(),

                    const SizedBox(height: 14),

                    _buildAvailableHeader(),

                    const SizedBox(height: 9),

                    _buildSearchAndFilters(),

                    const SizedBox(height: 11),

                    _buildSpacesContent(),

                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // API CONTENT
  // ============================================================

  Widget _buildSpacesContent() {
    return Obx(
          () {
        if (controller.isLoading.value &&
            controller.spaces.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 50,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.lightPrimary,
              ),
            ),
          );
        }

        if (controller.errorMessage.value != null &&
            controller.spaces.isEmpty) {
          return _buildErrorState();
        }

        final spaces = controller.filteredSpaces;

        if (spaces.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: spaces
              .map(
                (space) => Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: _buildSpaceCard(
                space,
              ),
            ),
          )
              .toList(),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
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
              controller.errorMessage.value ??
                  'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 8,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: controller.getSpaces,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.lightPrimary,
                foregroundColor: Colors.white,
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppColors.lightTextSecondary,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'No spaces found',
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try changing your search or filters.',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        38,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.gradientBlueStart,
            AppColors.gradientPurpleEnd,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.24,
                ),
              ),
            ),
            child: const Text(
              '✦  IRYAX SPACES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Find Your Perfect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            'Workspace Today',
            style: TextStyle(
              color: Color(0xFFFFD632),
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 9),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
            ),
            child: Text(
              'Discover premium co-working spaces, medical chambers,\n'
                  'meeting rooms & private offices tailored to your professional\n'
                  'needs',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            height: 36,
            padding: const EdgeInsets.only(
              left: 11,
              right: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                  size: 14,
                ),

                const SizedBox(width: 7),

                const Expanded(
                  child: Text(
                    'Search for spaces...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ),

                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          color:
                          AppColors.lightPrimary,
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 11,
                        color:
                        AppColors.lightPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          Obx(
                () {
              final spaces =
                  controller.spaces;

              final totalSeats = spaces.fold<int>(
                0,
                    (sum, item) =>
                sum + item.seatCount,
              );

              return Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: [
                  _heroStat(
                    icon:
                    Icons.home_work_outlined,
                    value:
                    '${spaces.length}+',
                    label: 'SPACES',
                  ),
                  _heroStat(
                    icon: Icons.groups_outlined,
                    value: '$totalSeats+',
                    label: 'SEATS',
                  ),
                  _heroStat(
                    icon:
                    Icons.medical_services_outlined,
                    value:
                    '${controller.medicalChambers.length}',
                    label: 'CHAMBERS',
                  ),
                  _heroStat(
                    icon:
                    Icons.access_time_rounded,
                    value: '24/7',
                    label: 'ACCESS',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return SizedBox(
      width: 55,
      child: Column(
        children: [
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: 0.13,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 13,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        10,
        10,
        10,
        11,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius:
                  BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.explore_outlined,
                  color: Colors.white,
                  size: 14,
                ),
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse Categories',
                      style: TextStyle(
                        color:
                        AppColors.lightTextPrimary,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Find the perfect space for your needs',
                      style: TextStyle(
                        color: AppColors
                            .lightTextSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: controller.clearFilters,
                borderRadius:
                BorderRadius.circular(8),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(8),
                    border: Border.all(
                      color:
                      AppColors.lightBorder,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 10,
                        color:
                        AppColors.lightPrimary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors
                              .lightPrimary,
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Obx(
                () => Row(
              children: [
                Expanded(
                  child: _categoryCard(
                    title: 'Co-Working',
                    subtitle:
                    'Flexible workspaces',
                    count:
                    '${controller.coworkingSpaces.length} Spaces',
                    icon: Icons
                        .business_center_outlined,
                    selected: controller
                        .selectedCategory
                        .value ==
                        'Co-Working',
                    onTap: () {
                      controller.changeCategory(
                        'Co-Working',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _categoryCard(
                    title: 'Meeting Rooms',
                    subtitle:
                    'Conference & events',
                    count: 'Coming Soon',
                    icon:
                    Icons.groups_outlined,
                    selected: controller
                        .selectedCategory
                        .value ==
                        'Meeting Rooms',
                    onTap: () {
                      controller.changeCategory(
                        'Meeting Rooms',
                      );
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
                  child: _categoryCard(
                    title:
                    'Medical Chambers',
                    subtitle:
                    'Healthcare spaces',
                    count:
                    '${controller.medicalChambers.length} Chambers',
                    icon: Icons
                        .medical_services_outlined,
                    selected: controller
                        .selectedCategory
                        .value ==
                        'Medical Chambers',
                    onTap: () {
                      controller.changeCategory(
                        'Medical Chambers',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _categoryCard(
                    title: 'Private Offices',
                    subtitle:
                    'Dedicated spaces',
                    count: controller
                        .spaces
                        .where(
                          (e) =>
                      e.isExclusive,
                    )
                        .length
                        .toString(),
                    icon:
                    Icons.lock_outline_rounded,
                    selected: controller
                        .selectedCategory
                        .value ==
                        'Private Offices',
                    onTap: () {
                      controller.changeCategory(
                        'Private Offices',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.softPurple
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected
                ? AppColors.lightPrimary
                : AppColors.lightBorder,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 29,
              height: 29,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.lightPrimary
                    : AppColors.softPurple,
                borderRadius:
                BorderRadius.circular(7),
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : AppColors.lightPrimary,
                size: 14,
              ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors
                          .lightTextPrimary,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors
                          .lightTextSecondary,
                      fontSize: 8,
                    ),
                  ),

                  const SizedBox(height: 1),

                  Text(
                    count,
                    style: const TextStyle(
                      color: AppColors
                          .lightTextSecondary,
                      fontSize: 8,
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

  // ============================================================
  // AVAILABLE HEADER
  // ============================================================

  Widget _buildAvailableHeader() {
    return Obx(
          () {
        final count =
            controller.filteredSpaces.length;

        final category =
            controller.selectedCategory.value;

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
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count Spaces Available',
                    style: const TextStyle(
                      color: AppColors
                          .lightTextPrimary,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Showing $category spaces',
                    style: const TextStyle(
                      color: AppColors
                          .lightTextSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Text(
                '↝ $count results',
                style: const TextStyle(
                  color:
                  AppColors.dashboardGreen,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SEARCH / FILTER
  // ============================================================

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        SizedBox(
          height: 35,
          child: TextField(
            controller:
            controller.searchController,
            cursorColor:
            AppColors.lightPrimary,
            style: const TextStyle(
              color:
              AppColors.lightTextPrimary,
              fontSize: 10,
            ),
            decoration: InputDecoration(
              hintText:
              'Search by name, address, or description...',
              hintStyle: const TextStyle(
                color: AppColors
                    .lightTextSecondary,
                fontSize: 9,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 14,
                color: AppColors
                    .lightTextSecondary,
              ),
              prefixIconConstraints:
              const BoxConstraints(
                minWidth: 34,
              ),
              filled: true,
              fillColor:
              AppColors.lightSurface,
              isDense: true,
              contentPadding:
              const EdgeInsets.symmetric(
                vertical: 9,
                horizontal: 8,
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(9),
                borderSide:
                const BorderSide(
                  color:
                  AppColors.lightBorder,
                ),
              ),
              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(9),
                borderSide:
                const BorderSide(
                  color:
                  AppColors.lightPrimary,
                ),
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
                  value:
                  controller.selectedCategory.value,
                  items: const [
                    'Co-Working',
                    'Medical Chambers',
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
                  value:
                  controller.selectedCabinType.value,
                  items: const [
                    'All Cabin Types',
                    'Normal',
                    'Exclusive',
                  ],
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
                  text: 'All',
                  icon:
                  Icons.auto_awesome_rounded,
                  selected: controller
                      .selectedFilter.value ==
                      'All',
                ),
              ),

              const SizedBox(width: 5),

              // Expanded(
              //   child: _filterChip(
              //     text: 'Top Rated',
              //     icon:
              //     Icons.star_border_rounded,
              //     selected: controller
              //         .selectedFilter.value ==
              //         'Top Rated',
              //   ),
              // ),

              const SizedBox(width: 5),

              Expanded(
                child: _filterChip(
                  text: 'Newest',
                  icon: Icons
                      .auto_awesome_outlined,
                  selected: controller
                      .selectedFilter.value ==
                      'Newest',
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: _filterChip(
                  text:
                  'Price Low to High',
                  icon:
                  Icons.currency_rupee,
                  selected: controller
                      .selectedFilter.value ==
                      'Price Low to High',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dropdownBox({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 33,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
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
            fontSize: 9,
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
        controller.changeFilter(
          text,
        );
      },
      borderRadius:
      BorderRadius.circular(18),
      child: Container(
        height: 29,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightPrimary
              : AppColors.lightSurface,
          borderRadius:
          BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.lightPrimary
                : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 10,
              color: selected
                  ? Colors.white
                  : AppColors
                  .lightTextPrimary,
            ),

            const SizedBox(width: 3),

            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppColors
                      .lightTextPrimary,
                  fontSize: 8.6,
                  fontWeight:
                  FontWeight.w600,
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

  Widget _buildSpaceCard(
      SpaceModel space,
      ) {
    final imageUrl =
    space.images.isNotEmpty
        ? _buildMediaUrl(
      space.images.first,
    )
        : '';

    final category =
    _getCategory(space);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightBorderStrong,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 145,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) {
                      return _imagePlaceholder();
                    },
                  )
                else
                  _imagePlaceholder(),

                Positioned(
                  left: 7,
                  top: 7,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: space.isChamber
                            ? AppColors
                            .dashboardRed
                            : AppColors
                            .lightTextPrimary,
                        fontSize: 8,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                if (space.isExclusive)
                  Positioned(
                    left: 7,
                    top: 30,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        AppColors.softOrange,
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Text(
                        '★ Exclusive',
                        style: TextStyle(
                          color: AppColors
                              .dashboardOrange,
                          fontSize: 8,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  right: 7,
                  top: 7,
                  child: Obx(
                        () {
                      final isFavorite =
                      wishlistController.isFavorite(
                        space.id,
                      );

                      final isUpdating =
                      wishlistController.isUpdating(
                        space.id,
                      );

                      return InkWell(
                        onTap: isUpdating
                            ? null
                            : () async {
                          await wishlistController
                              .toggleFavorite(
                            space,
                          );
                        },
                        borderRadius:
                        BorderRadius.circular(30),
                        child: Container(
                          width: 27,
                          height: 27,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFavorite
                                  ? AppColors.dashboardRed
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: isUpdating
                              ? const SizedBox(
                            width: 13,
                            height: 13,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color:
                              AppColors.dashboardRed,
                            ),
                          )
                              : Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons
                                .favorite_border_rounded,
                            size: 15,
                            color: isFavorite
                                ? AppColors.dashboardRed
                                : AppColors
                                .lightTextSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 7,
                  bottom: 7,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withValues(
                        alpha: 0.72,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        7,
                      ),
                    ),
                    child: Text(
                      '${_formatPrice(space.price)}/hour',
                      style:
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              9,
              8,
              9,
              8,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  space.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors
                        .lightTextPrimary,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                _spaceInfoRow(
                  Icons.location_on_outlined,
                  space.address,
                ),

                const SizedBox(height: 2),

                _spaceInfoRow(
                  Icons.access_time_outlined,
                  space.timing,
                ),

                const SizedBox(height: 5),

                _buildAmenities(
                  space,
                ),

                const SizedBox(height: 6),

                const Divider(
                  height: 1,
                  color:
                  AppColors.lightBorder,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .person_outline_rounded,
                      size: 10,
                      color: AppColors
                          .lightTextSecondary,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        '${space.seatCount} seats',
                        style:
                        const TextStyle(
                          color: AppColors
                              .lightTextSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 26,
                      child:
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes
                                .spaceDetails,
                            arguments: space,
                          );
                        },
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          AppColors
                              .lightPrimary,
                          foregroundColor:
                          Colors.white,
                          elevation: 0,
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 10,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              7,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons
                              .visibility_outlined,
                          size: 10,
                        ),
                        label: const Text(
                          'View',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AMENITIES
  // ============================================================

  Widget _buildAmenities(
      SpaceModel space,
      ) {
    final icons = <IconData>[];

    if (space.amenities.wifi) {
      icons.add(
        Icons.wifi_outlined,
      );
    }

    if (space.amenities.parking) {
      icons.add(
        Icons.local_parking_outlined,
      );
    }

    if (space.amenities.lockers) {
      icons.add(
        Icons.lock_outline_rounded,
      );
    }

    if (space.amenities.ac) {
      icons.add(
        Icons.ac_unit_rounded,
      );
    }

    if (space.amenities.coffee) {
      icons.add(
        Icons.coffee_outlined,
      );
    }

    if (space.amenities.printer) {
      icons.add(
        Icons.print_outlined,
      );
    }

    if (space.amenities.tv) {
      icons.add(
        Icons.tv_outlined,
      );
    }

    final displayed =
    icons.take(4).toList();

    final remaining =
        icons.length - displayed.length;

    return Row(
      children: [
        ...displayed.map(
              (icon) => Padding(
            padding:
            const EdgeInsets.only(
              right: 4,
            ),
            child: _facilityIcon(
              icon,
            ),
          ),
        ),

        if (remaining > 0)
          Text(
            '+$remaining',
            style: const TextStyle(
              color: AppColors
                  .lightTextSecondary,
              fontSize: 8,
            ),
          ),

        if (icons.isEmpty)
          const Text(
            'No amenities listed',
            style: TextStyle(
              color: AppColors
                  .lightTextSecondary,
              fontSize: 8.5,
            ),
          ),
      ],
    );
  }

  Widget _facilityIcon(
      IconData icon,
      ) {
    return Container(
      width: 19,
      height: 19,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius:
        BorderRadius.circular(5),
      ),
      child: Icon(
        icon,
        size: 9,
        color:
        AppColors.lightTextSecondary,
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.softPurple,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.lightPrimary,
        size: 30,
      ),
    );
  }

  String _getCategory(
      SpaceModel space,
      ) {
    if (space.isChamber) {
      return 'Medical Chamber';
    }

    if (space.isCafe) {
      return 'Cafe Workspace';
    }

    if (space.isExclusive) {
      return 'Private Office';
    }

    return 'Co-Working';
  }

  String _formatPrice(
      double price,
      ) {
    if (price % 1 == 0) {
      return '₹${price.toInt()}';
    }

    return '₹${price.toStringAsFixed(2)}';
  }

  String _buildMediaUrl(
      String path,
      ) {
    if (path.trim().isEmpty) {
      return '';
    }

    if (path.startsWith(
      'http://',
    ) ||
        path.startsWith(
          'https://',
        )) {
      return path;
    }

    final normalized =
    path.replaceAll(
      '\\',
      '/',
    );

    return 'https://spaceapi.iryax.com/$normalized';
  }

  Widget _spaceInfoRow(
      IconData icon,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 10,
          color:
          AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors
                  .lightTextSecondary,
              fontSize: 6.8,
            ),
          ),
        ),
      ],
    );
  }
}