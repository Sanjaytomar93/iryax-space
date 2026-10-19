import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/wishlist/controller/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.lightBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),

          Transform.translate(
            offset: const Offset(0, -14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              child: Column(
                children: [
                  _buildSummaryCard(),

                  const SizedBox(height: 14),

                  Obx(
                        () {
                      if (controller.isLoading.value &&
                          controller.items.isEmpty) {
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

                      if (controller.errorMessage.value.isNotEmpty &&
                          controller.items.isEmpty) {
                        return _buildErrorState();
                      }

                      final items =
                          controller.filteredItems;

                      if (controller.items.isEmpty) {
                        return _buildEmptyState();
                      }

                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 35,
                          ),
                          child: Center(
                            child: Text(
                              'No wishlist items match your search.',
                              style: TextStyle(
                                color:
                                AppColors.lightTextSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: items
                            .map(
                              (item) => Padding(
                            padding:
                            const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child:
                            _buildWishlistCard(
                              item,
                            ),
                          ),
                        )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  _buildFooter(),

                  const SizedBox(height: 75),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        38,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEA3F5A),
            Color(0xFFC91849),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.14,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius:
                  BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Obx(
                      () => Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Wishlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${controller.totalSaved} spaces saved',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 38,
            child: TextField(
              controller:
              controller.searchController,
              cursorColor: Colors.white,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
              decoration: InputDecoration(
                hintText: 'Search wishlist...',
                hintStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                  size: 15,
                ),
                prefixIconConstraints:
                const BoxConstraints(
                  minWidth: 34,
                ),
                filled: true,
                fillColor:
                Colors.white.withValues(
                  alpha: 0.12,
                ),
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 10,
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                    Colors.white.withValues(
                      alpha: 0.28,
                    ),
                  ),
                ),
                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                  borderSide:
                  const BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
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
              color: Colors.black
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
              onTap: controller.clearAll,
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
                AppColors.dashboardRed,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistCard(
      SpaceModel item,
      ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightBorderStrong,
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 145,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) {
                    return Container(
                      color:
                      AppColors.softPurple,
                      alignment:
                      Alignment.center,
                      child: const Icon(
                        Icons
                            .image_not_supported_outlined,
                        color: AppColors
                            .lightPrimary,
                      ),
                    );
                  },
                ),

                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration:
                    BoxDecoration(
                      color: item.category ==
                          'Medical Chamber'
                          ? AppColors.softRed
                          : Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        color: item.category ==
                            'Medical Chamber'
                            ? AppColors
                            .dashboardRed
                            : AppColors
                            .lightTextPrimary,
                        fontSize: 8.5,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 8,
                  top: 8,
                  child: InkWell(
                    onTap: () {
                      controller.removeItem(
                        item.id,
                      );
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment:
                      Alignment.center,
                      decoration:
                      const BoxDecoration(
                        color:
                        AppColors.dashboardRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      AppColors.dashboardRed,
                      borderRadius:
                      BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 10,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Saved',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withValues(
                        alpha: 0.72,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: Text(
                      '${item.price}/hour',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
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
              10,
              9,
              10,
              9,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color:
                    AppColors.lightTextPrimary,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                _infoRow(
                  Icons.location_on_outlined,
                  item.location,
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors
                          .dashboardOrange,
                      size: 11,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${item.rating}',
                      style: const TextStyle(
                        color: AppColors
                            .lightTextPrimary,
                        fontSize: 9,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${item.reviews} reviews)',
                      style: const TextStyle(
                        color: AppColors
                            .lightTextSecondary,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    _facilityIcon(
                      Icons.wifi_rounded,
                    ),
                    const SizedBox(width: 5),
                    _facilityIcon(
                      Icons
                          .business_center_outlined,
                    ),
                    const SizedBox(width: 5),
                    _facilityIcon(
                      Icons.lock_outline,
                    ),
                    const SizedBox(width: 5),
                    _facilityIcon(
                      Icons
                          .desktop_windows_outlined,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Text(
                        '+5',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                const Divider(
                  height: 1,
                  color: AppColors.lightBorder,
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 11,
                      color: AppColors
                          .lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${item.seatCount} seats',
                        style: const TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 28,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // final space =
                          // SpaceModel(
                          //   id: item.id,
                          //   name: item.name,
                          //   category:
                          //   item.category,
                          //   location:
                          //   item.location,
                          //   imageUrl:
                          //   item.imageUrl,
                          //   price: item.price,
                          //   timing:
                          //   '9:00 AM - 9:00 PM',
                          //   rating:
                          //   item.rating,
                          //   reviews:
                          //   item.reviews,
                          //   seats:
                          //   item.seats,
                          // );
                          //
                          // Get.toNamed(
                          //   AppRoutes
                          //       .spaceDetails,
                          //   arguments: space,
                          // );


                          Get.toNamed(
                            AppRoutes.spaceDetails,
                            arguments: item,
                          );
                        },
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.dashboardRed,
                          foregroundColor:
                          Colors.white,
                          elevation: 0,
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 12,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 11,
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

  Widget _facilityIcon(
      IconData icon,
      ) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 11,
        color: AppColors.lightTextSecondary,
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String text,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 11,
          color: AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color:
              AppColors.lightTextSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
                color: AppColors.dashboardRed,
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