import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
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
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            // Build only visible cards so their large network images do not
            // all download together when the Space tab first opens.
            itemCount: 3 + contentCount,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHero();
              if (index == 1) {
                return Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _buildCategories(),
                  ),
                );
              }
              if (index == 2) {
                return Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 11),
                    child: Column(
                      children: [
                        _buildAvailableHeader(),
                        const SizedBox(height: 9),
                        _buildSearchAndFilters(),
                      ],
                    ),
                  ),
                );
              }

              final cardIndex = index - 3;
              if (loading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightPrimary,
                    ),
                  ),
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
                  cardIndex == spaces.length - 1 ? 70 : 16,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try changing your search or filters.',
            style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 10),
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.25, -1),
          end: Alignment(-0.15, 1),
          colors: [Color(0xFF5B4FE9), Color(0xFF6D3FE0), Color(0xFF7B33D6)],
          stops: [0, 0.55, 1],
        ),
      ),
      child: Column(
        children: [
          Container(
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
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.33,
                    height: 13 / 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Find Your Perfect',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              height: 29 / 20,
            ),
          ),
          const Text(
            'Workspace Today',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFD84D),
              fontSize: 21,
              fontWeight: FontWeight.w700,
              height: 29 / 20,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'Discover premium co-working spaces, medical chambers, '
              'meeting rooms & private offices tailored to your professional needs',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 20 / 12.9,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 50,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 6),
                Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search for spaces...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          color: Color(0xFF4338CA),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 16 / 13,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: Color(0xFF4338CA),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                Expanded(
                  child: _heroStat(
                    icon: Icons.groups_outlined,
                    value: '$totalSeats+',
                    label: 'SEATS',
                  ),
                ),
                Expanded(
                  child: _heroStat(
                    icon: Icons.star_border_rounded,
                    value: '4.8★',
                    label: 'RATING',
                  ),
                ),
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
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: Colors.white, size: 15),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 16 / 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 9,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.51,
            height: 10 / 8.5,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141E143C),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5B4FE9), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.explore_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse Categories',
                      style: TextStyle(
                        color: Color(0xFF1E1B2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 18 / 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Find the perfect space for your needs',
                      style: TextStyle(
                        color: Color(0xFF8A8A99),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 13 / 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: controller.clearFilters,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE7E7F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 11,
                        color: Color(0xFF4338CA),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xFF4338CA),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 14 / 11.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            final selected = controller.selectedCategory.value;
            final offices =
                controller.spaces.where((e) => e.isExclusive).length;

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
                        onTap: () {
                          controller.changeCategory('Co-Working');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _categoryCard(
                        title: 'Meeting Rooms',
                        subtitle: 'Conference & events',
                        count: '12 Rooms',
                        icon: Icons.groups_outlined,
                        selected: selected == 'Meeting Rooms',
                        onTap: () {
                          controller.changeCategory('Meeting Rooms');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: _categoryCard(
                        title: 'Medical Chambers',
                        subtitle: 'Healthcare spaces',
                        count: '${controller.medicalChambers.length} Chambers',
                        icon: Icons.medical_services_outlined,
                        selected: selected == 'Medical Chambers',
                        onTap: () {
                          controller.changeCategory('Medical Chambers');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _categoryCard(
                        title: 'Cafe & Dining',
                        subtitle: 'Cafes & dining tables',
                        count:
                            '${controller.cafeAndDiningSpaces.length} Tables',
                        icon: Icons.restaurant_menu_rounded,
                        selected: selected == 'Cafe & Dining',
                        onTap: () {
                          controller.changeCategory('Cafe & Dining');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                _categoryCard(
                  title: 'Private Offices',
                  subtitle: 'Dedicated spaces for focused work',
                  count: '$offices Offices',
                  icon: Icons.lock_outline_rounded,
                  selected: selected == 'Private Offices',
                  onTap: () {
                    controller.changeCategory('Private Offices');
                  },
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
          color: selected ? const Color(0xFFF5F4FE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      selected
                          ? const Color(0xFF5B4FE9)
                          : const Color(0xFFE7E7F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? null : const Color(0xFFF1F0FB),
                      gradient:
                          selected
                              ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4F7CFB), Color(0xFF5B4FE9)],
                              )
                              : null,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: selected ? Colors.white : const Color(0xFF4338CA),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1E1B2E),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 15 / 12.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8A8A99),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 12 / 10.5,
                          ),
                        ),
                        Text(
                          count,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8A8A99),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 12 / 10,
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
            right: -6,
            top: -6,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
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
    return Column(
      children: [
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller.searchController,
            cursorColor: AppColors.lightPrimary,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 11,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name, address, or description...',
              hintStyle: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 10,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 14,
                color: AppColors.lightTextSecondary,
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              filled: true,
              fillColor: AppColors.lightSurface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 8,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
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
                  value: controller.selectedCategory.value,
                  items: const [
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
                  text: 'All',
                  icon: Icons.auto_awesome_rounded,
                  selected: controller.selectedFilter.value == 'All',
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _filterChip(
                  text: 'Top Rated',
                  icon: Icons.workspace_premium_outlined,
                  selected: controller.selectedFilter.value == 'Top Rated',
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _filterChip(
                  text: 'New Added',
                  icon: Icons.auto_awesome_outlined,
                  selected: controller.selectedFilter.value == 'New Added',
                ),
              ),
              const SizedBox(width: 5),
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
    );
  }

  Widget _dropdownBox({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
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
          items:
              items
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightPrimary : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(18),
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
            Text(
              text,
              maxLines: 1,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.lightTextPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
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
    final imageUrl = _coverImageUrl(space);
    final category = _getCategory(space);
    final badge = _categoryBadgeColors(space);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 170,
                    // Cards are much smaller than the source PNGs. Keeping a
                    // card-sized cache avoids repeated large image decodes.
                    memCacheWidth: 720,
                    maxWidthDiskCache: 720,
                    maxHeightDiskCache: 480,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    placeholder:
                        (_, __) => const ColoredBox(
                          color: Color(0xFFF3F5FA),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF5B4FE9),
                              ),
                            ),
                          ),
                        ),
                    errorWidget: (_, __, ___) => _imagePlaceholder(),
                  )
                else
                  _imagePlaceholder(),
                const ColoredBox(color: Color(0x26000000)),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badge.$1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: badge.$2,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 12 / 10.5,
                      ),
                    ),
                  ),
                ),
                if (space.isExclusive)
                  Positioned(
                    left: 10,
                    top: 38,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4DA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '★ Exclusive',
                        style: TextStyle(
                          color: Color(0xFF8A5B00),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 12 / 10.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Obx(() {
                    final isFavorite = wishlistController.isFavorite(space.id);
                    final isUpdating = wishlistController.isUpdating(space.id);

                    return Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap:
                            isUpdating
                                ? null
                                : () =>
                                    wishlistController.toggleFavorite(space),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Center(
                            child:
                                isUpdating
                                    ? const SizedBox(
                                      width: 13,
                                      height: 13,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.6,
                                        color: Color(0xFFE4415B),
                                      ),
                                    )
                                    : Icon(
                                      isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 15,
                                      color:
                                          isFavorite
                                              ? const Color(0xFFE4415B)
                                              : const Color(0xFFB4B4C2),
                                    ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Positioned(
                  right: 8,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xD114121E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatPrice(space.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 14 / 12,
                          ),
                        ),
                        const Text(
                          '/hour',
                          style: TextStyle(
                            color: Color(0xBFFFFFFF),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 11 / 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E1B2E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 18 / 15,
                  ),
                ),
                const SizedBox(height: 6),
                _spaceInfoRow(Icons.location_on_outlined, space.address),
                if (space.timing.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _spaceInfoRow(Icons.access_time_rounded, space.timing),
                ],
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text(
                      '★',
                      style: TextStyle(
                        color: Color(0xFFF5A623),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 14 / 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: TextStyle(
                        color: Color(0xFF1E1B2E),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 14 / 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '(24 reviews)',
                      style: TextStyle(
                        color: Color(0xFF8A8A99),
                        fontSize: 11,
                        height: 14 / 12,
                      ),
                    ),
                  ],
                ),
                _buildAmenities(space),
                const SizedBox(height: 10),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE7E7F0),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      size: 14,
                      color: Color(0xFF8A8A99),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${space.seatCount} seats',
                        style: const TextStyle(
                          color: Color(0xFF8A8A99),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 14 / 12,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.spaceDetails, arguments: space);
                        },
                        borderRadius: BorderRadius.circular(9),
                        child: Ink(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5B4FE9), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 13,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  height: 14 / 12,
                                ),
                              ),
                            ],
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

  Widget _buildAmenities(SpaceModel space) {
    final icons = <IconData>[];
    final amenities = space.amenities;

    if (amenities.wifi) icons.add(Icons.wifi_rounded);
    if (amenities.lockers) icons.add(Icons.lock_outline_rounded);
    if (amenities.tv) icons.add(Icons.desktop_windows_outlined);
    if (amenities.coffee) icons.add(Icons.coffee_outlined);
    if (amenities.printer) icons.add(Icons.print_outlined);
    if (amenities.ac) icons.add(Icons.ac_unit_rounded);
    if (amenities.parking) icons.add(Icons.local_parking_outlined);
    if (amenities.comfortSeating) {
      icons.add(Icons.chair_alt_outlined);
    }
    if (amenities.privateWashroom) icons.add(Icons.wc_outlined);
    if (amenities.secureAccess) icons.add(Icons.vpn_key_outlined);
    if (amenities.gym) icons.add(Icons.fitness_center);
    if (amenities.phone) icons.add(Icons.phone_outlined);

    if (icons.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayed = icons.take(3).toList();
    final remaining = icons.length - displayed.length;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          for (final icon in displayed) ...[
            _facilityIcon(icon),
            const SizedBox(width: 8),
          ],
          if (remaining > 0)
            Text(
              '+$remaining',
              style: const TextStyle(
                color: Color(0xFF8A8A99),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 13 / 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _facilityIcon(IconData icon) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FA),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 13, color: const Color(0xFF8A8A99)),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _imagePlaceholder() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F5FA), Colors.white],
        ),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, color: Color(0xFFB4B4C2), size: 32),
      ),
    );
  }

  String _getCategory(SpaceModel space) {
    if (space.isChamber) return 'Medical Chamber';
    if (space.isCafe) return 'Cafe';
    if (space.isExclusive) return 'Private Office';
    return 'Workspace';
  }

  (Color, Color) _categoryBadgeColors(SpaceModel space) {
    if (space.isChamber) {
      return (const Color(0xFFFDECEC), const Color(0xFFC0392B));
    }
    if (space.isExclusive) {
      return (const Color(0xFFEAF6EA), const Color(0xFF1F7A3D));
    }
    if (space.isCafe) {
      return (const Color(0xFFFFF4DA), const Color(0xFF8A5B00));
    }
    return (Colors.white.withValues(alpha: 0.92), const Color(0xFF1E1B2E));
  }

  String _formatPrice(double price) {
    if (price % 1 != 0) {
      return '₹${price.toStringAsFixed(2)}';
    }

    final digits = price.toInt().abs().toString();
    if (digits.length <= 3) {
      return '₹$digits';
    }

    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final groups = <String>[];
    var rest = head;
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      groups.insert(0, rest);
    }

    final sign = price < 0 ? '-' : '';
    return '$sign₹${groups.join(',')},$tail';
  }

  String _coverImageUrl(SpaceModel space) {
    const preferred = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    String? fallback;

    for (final raw in space.images) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;

      final lower = trimmed.toLowerCase();
      if (preferred.any(lower.endsWith)) {
        return _buildMediaUrl(trimmed);
      }
      fallback ??= trimmed;
    }

    if (fallback == null) return '';
    return _buildMediaUrl(fallback);
  }

  String _buildMediaUrl(String path) {
    var value = path.trim().replaceAll('\\', '/');
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    while (value.startsWith('/')) {
      value = value.substring(1);
    }

    return 'https://spaceapi.iryax.com/$value';
  }

  Widget _spaceInfoRow(IconData icon, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF8A8A99)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8A8A99),
              fontSize: 11,
              height: 14 / 11,
            ),
          ),
        ),
      ],
    );
  }
}
