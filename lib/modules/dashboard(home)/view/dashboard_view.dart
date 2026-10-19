import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/dashboard(home)/controller/home_controller.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
  });

  // SpacesController get spacesController =>
  //     Get.find<SpacesController>();

  HomeController get homeController =>
      Get.find<HomeController>();

  BookingsController get bookingsController =>
      Get.find<BookingsController>();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.lightBackground,
      child: RefreshIndicator(
        color: AppColors.lightPrimary,
        onRefresh: () async {
          await Future.wait([
            homeController.loadDashboard(),
            // spacesController.refreshSpaces(),
            bookingsController.loadBookings(),

          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24,
          ),

          children: [
            _buildHeader(),

            const SizedBox(height: 16),

            _buildStatsGrid(),

            const SizedBox(height: 14),

            _buildBookingSearch(),

            const SizedBox(height: 8),

            _buildBookingDateFilter(  context,),

            const SizedBox(height: 8),

            _buildBookingFilters(),

            const SizedBox(height: 10),

            _buildBookingCount(),

            _buildClearFilters(),


            const SizedBox(height: 12),

            _buildDashboardBookings(),

            const SizedBox(height: 70),
          ],
          // children: [
          //   _buildHeader(),
          //
          //   const SizedBox(height: 16),
          //
          //   // _buildProfileCompletionCard(),
          //
          //   // const SizedBox(height: 16),
          //
          //   _buildStatsGrid(),
          //
          //   const SizedBox(height: 20),
          //
          //   // _buildSpacesHeader(),
          //
          //   // const SizedBox(height: 12),
          //
          //   // _buildSpaceSearch(),
          //
          //   // const SizedBox(height: 10),
          //
          //   // _buildCategoryFilters(),
          //
          //   // const SizedBox(height: 10),
          //
          //   // _buildCabinTypeFilters(),
          //
          //   // const SizedBox(height: 16),
          //
          //   // _buildSpacesList(),
          //
          //   const SizedBox(height: 70),
          // ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final name = StorageService.userName.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'My ',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: 'Dashboard',
                style: TextStyle(
                  color: AppColors.lightPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        Text(
          name.isNotEmpty
              ? 'Welcome back, $name'
              : 'Welcome back',
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

 ////  Booking Search  ////

  Widget _buildBookingSearch() {
    return SizedBox(
      height: 42,
      child: TextField(
        controller:
        bookingsController.searchController,
        onChanged:
        bookingsController.updateSearch,

        style: const TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          hintText: 'Search bookings...',
          hintStyle: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 10,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 17,
            color:
            AppColors.lightTextSecondary,
          ),
          filled: true,
          fillColor: AppColors.lightSurface,
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.lightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.lightPrimary,
            ),
          ),
        ),
      ),
    );
  }

  ///Date Filter ///


  Widget _buildBookingDateFilter(
      BuildContext context,
      ) {
    return Obx(
          () {
        final selected =
            bookingsController
                .selectedBookingDate
                .value;

        final text =
        selected == null
            ? 'mm/dd/yyyy'
            : '${selected.month.toString().padLeft(2, '0')}/'
            '${selected.day.toString().padLeft(2, '0')}/'
            '${selected.year}';

        return InkWell(
          onTap: () async {
            final picked =
            await showDatePicker(
              context: context,
              initialDate:
              selected ??
                  DateTime.now(),
              firstDate:
              DateTime(2020),
              lastDate:
              DateTime(2035),
            );

            if (picked != null) {
              bookingsController
                  .changeBookingDate(
                picked,
              );
            }
          },
          borderRadius:
          BorderRadius.circular(
            10,
          ),
          child: Container(
            height: 40,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color:
              AppColors.lightSurface,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              border: Border.all(
                color:
                AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: AppColors
                          .lightTextSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),

                if (selected != null)
                  GestureDetector(
                    onTap: () {
                      bookingsController
                          .changeBookingDate(
                        null,
                      );
                    },
                    child: const Padding(
                      padding:
                      EdgeInsets.only(
                        right: 8,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors
                            .lightTextSecondary,
                      ),
                    ),
                  ),

                const Icon(
                  Icons
                      .calendar_today_outlined,
                  size: 14,
                  color: AppColors
                      .lightTextSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingFilters() {
    return Obx(
          () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child:
                _dashboardDropdown(
                  value:
                  bookingsController
                      .selectedStatus
                      .value,
                  items: const [
                    'All Status',
                    'Pending',
                    'Confirmed',
                    'Active',
                    'Completed',
                    'Cancelled',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      bookingsController
                          .changeStatus(
                        value,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child:
                _dashboardDropdown(
                  value:
                  bookingsController
                      .selectedType
                      .value,
                  items: const [
                    'All Types',
                    'Co-Working Space',
                    'Medical Chamber',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      bookingsController
                          .changeType(
                        value,
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _dashboardDropdown(
            value:
            bookingsController
                .selectedPaymentStatus
                .value,
            items: const [
              'Payment Status',
              'Paid',
              'Pending',
            ],
            onChanged: (value) {
              if (value != null) {
                bookingsController
                    .changePaymentStatus(
                  value,
                );
              }
            },
          ),
        ],
      ),
    );
  }
  ///DahBoardDropdown///

  Widget _dashboardDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?>
    onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color:
            AppColors.lightTextSecondary,
          ),
          style: const TextStyle(
            color:
            AppColors.lightTextPrimary,
            fontSize: 10,
          ),
          dropdownColor:
          AppColors.lightSurface,
          items:
          items.map(
                (item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              );
            },
          ).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }


  ///Vooking Count


  Widget _buildBookingCount() {
    return Obx(
          () => Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Showing ${bookingsController.filteredBookings.length} of ${bookingsController.bookings.length} bookings',          style: const TextStyle(
            color:
            AppColors.lightTextSecondary,
            fontSize: 9,
          ),
        ),
      ),
    );
  }


  Widget _buildClearFilters() {
    return Obx(
          () {
        final hasFilters =
            bookingsController
                .searchQuery.value
                .isNotEmpty ||
                bookingsController
                    .selectedStatus
                    .value !=
                    'All Status' ||
                bookingsController
                    .selectedType
                    .value !=
                    'All Types' ||
                bookingsController
                    .selectedPaymentStatus
                    .value !=
                    'Payment Status' ||
                bookingsController
                    .selectedBookingDate
                    .value !=
                    null;

        if (!hasFilters) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment:
          Alignment.centerRight,
          child: TextButton.icon(
            onPressed:
            bookingsController
                .clearDashboardFilters,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 14,
            ),
            label: const Text(
              'Clear filters',
            ),
          ),
        );
      },
    );
  }


  ///Bookings


  Widget _buildDashboardBookings() {
    return Obx(
          () {
        if (bookingsController
            .isLoadingBookings.value &&
            bookingsController
                .bookings.isEmpty) {
          return const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 40,
            ),
            child: Center(
              child:
              CircularProgressIndicator(
                color:
                AppColors.lightPrimary,
              ),
            ),
          );
        }

        if (bookingsController
            .bookingError.value !=
            null &&
            bookingsController
                .bookings.isEmpty) {
          return Center(
            child: Text(
              bookingsController
                  .bookingError.value ??
                  'Unable to load bookings.',
              style: const TextStyle(
                color: AppColors
                    .lightTextSecondary,
              ),
            ),
          );
        }

        final bookings =
            bookingsController
                .filteredBookings;

        if (bookings.isEmpty) {
          return const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 35,
            ),
            child: Center(
              child: Text(
                'No bookings match your filters.',
                style: TextStyle(
                  color: AppColors
                      .lightTextSecondary,
                ),
              ),
            ),
          );
        }

        return Column(
          children:
          bookings
              .map(
                (booking) =>
                Padding(
                  padding:
                  const EdgeInsets
                      .only(
                    bottom: 12,
                  ),
                  child:
                  _dashboardBookingCard(
                    booking,
                  ),
                ),
          )
              .toList(),
        );
      },
    );
  }

  // DAShboard bookingcard //


  Widget _dashboardBookingCard(
      BookingModel booking,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              alpha: 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            booking.spaceName,
            style: const TextStyle(
              color:
              AppColors.lightTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .location_on_outlined,
                      size: 11,
                      color: AppColors
                          .lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.location,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          color: AppColors
                              .lightTextSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // const SizedBox(width: 8),
              //
              // Text(
              //   booking.customerName,
              //   style: const TextStyle(
              //     color: AppColors
              //         .lightTextSecondary,
              //     fontSize: 8,
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 10),

          const Divider(
            height: 1,
            color: AppColors.lightBorder,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Date & time',
                  style: TextStyle(
                    color: AppColors
                        .lightTextSecondary,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${booking.startDate}  ${booking.startTime}',
                style: const TextStyle(
                  color: AppColors
                      .lightTextPrimary,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(
                    color: AppColors
                        .lightTextSecondary,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              _dashboardStatusChip(
                booking,
              ),

              const SizedBox(width: 5),

              _dashboardPaymentChip(
                booking,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Amount',
                  style: TextStyle(
                    color: AppColors
                        .lightTextSecondary,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              Text(
                booking.amount,
                style: const TextStyle(
                  color:
                  AppColors.lightPrimary,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    bookingsController
                        .openBookingDetails(
                      booking,
                    );
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 12,
                  ),
                  label: const Text(
                    'View',
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.download_outlined,
                    size: 12,
                  ),
                  label: const Text(
                    'Invoice',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashboardStatusChip(
      BookingModel booking,
      ) {
    final text =
    bookingsController.bookingStatusText(
      booking.status,
    );

    Color textColor;
    Color backgroundColor;

    switch (booking.status) {
      case BookingStatus.pending:
        textColor =
            AppColors.dashboardOrange;
        backgroundColor =
            AppColors.softOrange;
        break;

      case BookingStatus.confirmed:
        textColor =
            AppColors.dashboardBlue;
        backgroundColor =
            AppColors.softBlue;
        break;

      case BookingStatus.active:
        textColor =
            AppColors.dashboardGreen;
        backgroundColor =
            AppColors.softGreen;
        break;

      case BookingStatus.completed:
        textColor =
            AppColors.dashboardPurple;
        backgroundColor =
            AppColors.softPurple;
        break;

      case BookingStatus.cancelled:
        textColor =
            AppColors.dashboardRed;
        backgroundColor =
            AppColors.softRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _dashboardPaymentChip(
      BookingModel booking,
      ) {
    final isPaid =
        booking.paymentStatus ==
            PaymentStatus.paid;

    final text =
    bookingsController.paymentStatusText(
      booking.paymentStatus,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.softGreen
            : AppColors.softOrange,
        borderRadius:
        BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isPaid
              ? AppColors.dashboardGreen
              : AppColors.dashboardOrange,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE COMPLETION
  // ============================================================

  Widget _buildProfileCompletionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12,
      ),
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
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightSurface,
                  border: Border.all(
                    color: AppColors.dashboardGreen,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '100%',
                      style: TextStyle(
                        color: AppColors.dashboardGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'COMPLETE',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

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

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _smallPill(
                          'Completed: ',
                          '100%',
                          AppColors.dashboardGreen,
                        ),
                        _smallPill(
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

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: 1,
              minHeight: 5,
              backgroundColor: AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.dashboardGreen,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '✓ 100% complete! 🎉',
              style: TextStyle(
                color: AppColors.dashboardGreen,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.gradientBlueStart,
                    AppColors.gradientPurpleEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton.icon(
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.profile,
                  );
                },
                icon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 16,
                ),
                label: const Text(
                  'View Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallPill(
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
        color: AppColors.lightSurface,
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

  // ============================================================
  // STATS
  //
  // Booking APIs are not integrated yet.
  // Keep these UI cards for now.
  // We will replace the values with actual user booking data later.
  // ============================================================


  void _applyDashboardStatFilter(
      String status,
      ) {
    // Clear search/date/type/payment first,
    // so clicking a stats card shows the complete
    // set for that status.
    bookingsController
        .clearDashboardFilters();

    if (status != 'All Status') {
      bookingsController
          .changeStatus(status);
    }
  }

  Widget _buildStatsGrid() {
    return Obx(
          () {
        if (homeController.isLoading.value) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 32,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightBorder,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color:
                AppColors.lightPrimary,
              ),
            ),
          );
        }

        if (homeController
            .errorMessage.value !=
            null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              18,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color:
                  AppColors.dashboardRed,
                  size: 28,
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  homeController
                      .errorMessage.value ??
                      'Unable to load dashboard.',
                  textAlign:
                  TextAlign.center,
                  style: const TextStyle(
                    color: AppColors
                        .lightTextSecondary,
                    fontSize: 9,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed:
                    homeController
                        .loadDashboard,
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      AppColors
                          .lightPrimary,
                      foregroundColor:
                      Colors.white,
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

        final selectedStatus =
            bookingsController
                .selectedStatus.value;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'TOTAL',
                    value:
                    '${homeController.totalBookings.value}',
                    subtitle: 'all reservations',
                    icon: Icons.inbox_outlined,
                    iconColor:
                    AppColors.lightPrimary,
                    iconBg:
                    AppColors.softPurple,
                    selected:
                    selectedStatus ==
                        'All Status',
                    onTap: () {
                      _applyDashboardStatFilter(
                        'All Status',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(
                    title: 'PENDING',
                    value:
                    '${homeController.pendingBookings.value}',
                    subtitle:
                    'awaiting confirmation',
                    icon:
                    Icons.access_time_rounded,
                    iconColor:
                    AppColors.dashboardOrange,
                    iconBg:
                    AppColors.softOrange,
                    selected:
                    selectedStatus ==
                        'Pending',
                    onTap: () {
                      _applyDashboardStatFilter(
                        'Pending',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'CONFIRMED',
                    value:
                    '${homeController.confirmedBookings.value}',
                    subtitle:
                    'approved reservations',
                    icon:
                    Icons.check_circle_outline,
                    iconColor:
                    AppColors.dashboardBlue,
                    iconBg:
                    AppColors.softBlue,
                    selected:
                    selectedStatus ==
                        'Confirmed',
                    onTap: () {
                      _applyDashboardStatFilter(
                        'Confirmed',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(
                    title: 'ACTIVE',
                    value:
                    '${homeController.activeBookings.value}',
                    subtitle:
                    'active & confirmed',
                    icon: Icons.home_outlined,
                    iconColor:
                    AppColors.dashboardGreen,
                    iconBg:
                    AppColors.softGreen,
                    selected:
                    selectedStatus ==
                        'Active',
                    onTap: () {
                      _applyDashboardStatFilter(
                        'Active',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'COMPLETED',
                    value:
                    '${homeController.completedBookings.value}',
                    subtitle:
                    'completed reservations',
                    icon:
                    Icons.check_circle_outline,
                    iconColor:
                    AppColors.dashboardPurple,
                    iconBg:
                    AppColors.softPurple,
                    selected:
                    selectedStatus ==
                        'Completed',
                    onTap: () {
                      _applyDashboardStatFilter(
                        'Completed',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(
                    title: 'CANCELLED',
                    value:
                    '${homeController.cancelledBookings.value}',
                    subtitle:
                    'cancelled reservations',
                    icon:
                    Icons.cancel_outlined,
                    iconColor:
                    AppColors.dashboardRed,
                    iconBg:
                    AppColors.softRed,
                    selected:
                    selectedStatus ==
                        'Cancelled',
                    onTap: () {
                      _applyDashboardStatFilter(
                        'Cancelled',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(12),
      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 180,
        ),
        padding:
        const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? iconBg
              : AppColors.lightSurface,
          borderRadius:
          BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? iconColor
                : AppColors.lightBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? iconColor
                          : AppColors
                          .lightTextSecondary,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius:
                    BorderRadius.circular(
                      7,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              value,
              style: const TextStyle(
                color: AppColors
                    .lightTextPrimary,
                fontSize: 18,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 1),

            Text(
              subtitle,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors
                    .lightTextSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SPACES HEADER
  // ============================================================

  // Widget _buildSpacesHeader() {
  //   return Obx(
  //         () {
  //       final count =
  //           spacesController.filteredSpaces.length;
  //
  //       return Row(
  //         children: [
  //           Container(
  //             width: 34,
  //             height: 34,
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: AppColors.softPurple,
  //               borderRadius: BorderRadius.circular(9),
  //             ),
  //             child: const Icon(
  //               Icons.business_center_outlined,
  //               color: AppColors.lightPrimary,
  //               size: 18,
  //             ),
  //           ),
  //
  //           const SizedBox(width: 10),
  //
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Available Spaces',
  //                   style: TextStyle(
  //                     color: AppColors.lightTextPrimary,
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.w700,
  //                   ),
  //                 ),
  //
  //                 const SizedBox(height: 2),
  //
  //                 Text(
  //                   '$count spaces available',
  //                   style: const TextStyle(
  //                     color: AppColors.lightTextSecondary,
  //                     fontSize: 9,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           TextButton(
  //             onPressed: () {
  //               // Spaces is bottom-navigation tab.
  //               // Keep this available if NavigationController
  //               // is later used to switch tabs directly.
  //             },
  //             child: const Text(
  //               'Explore',
  //               style: TextStyle(
  //                 color: AppColors.lightPrimary,
  //                 fontSize: 10,
  //                 fontWeight: FontWeight.w700,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // ============================================================
  // SEARCH
  // ============================================================

  // Widget _buildSpaceSearch() {
  //   return SizedBox(
  //     height: 42,
  //     child: TextField(
  //       controller:
  //       spacesController.searchController,
  //       cursorColor: AppColors.lightPrimary,
  //       style: const TextStyle(
  //         color: AppColors.lightTextPrimary,
  //         fontSize: 11,
  //       ),
  //       decoration: InputDecoration(
  //         hintText:
  //         'Search spaces by name, location...',
  //         hintStyle: const TextStyle(
  //           color: AppColors.lightTextSecondary,
  //           fontSize: 10,
  //         ),
  //         prefixIcon: const Icon(
  //           Icons.search_rounded,
  //           color: AppColors.lightTextSecondary,
  //           size: 18,
  //         ),
  //         filled: true,
  //         fillColor: AppColors.lightSurface,
  //         isDense: true,
  //         contentPadding:
  //         const EdgeInsets.symmetric(
  //           horizontal: 12,
  //           vertical: 10,
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius:
  //           BorderRadius.circular(11),
  //           borderSide: const BorderSide(
  //             color: AppColors.lightBorder,
  //           ),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius:
  //           BorderRadius.circular(11),
  //           borderSide: const BorderSide(
  //             color: AppColors.lightPrimary,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  // Widget _buildCategoryFilters() {
  //   return Obx(
  //         () {
  //       final selected =
  //           spacesController.selectedCategory.value;
  //
  //       return SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           children: [
  //             _filterChip(
  //               text: 'Co-Working',
  //               selected:
  //               selected == 'Co-Working',
  //               onTap: () {
  //                 spacesController.changeCategory(
  //                   'Co-Working',
  //                 );
  //               },
  //             ),
  //
  //             const SizedBox(width: 7),
  //
  //             _filterChip(
  //               text: 'Medical Chambers',
  //               selected:
  //               selected == 'Medical Chambers',
  //               onTap: () {
  //                 spacesController.changeCategory(
  //                   'Medical Chambers',
  //                 );
  //               },
  //             ),
  //
  //             const SizedBox(width: 7),
  //
  //             _filterChip(
  //               text: 'Private Offices',
  //               selected:
  //               selected == 'Private Offices',
  //               onTap: () {
  //                 spacesController.changeCategory(
  //                   'Private Offices',
  //                 );
  //               },
  //             ),
  //
  //             const SizedBox(width: 7),
  //
  //             _filterChip(
  //               text: 'Meeting Rooms',
  //               selected:
  //               selected == 'Meeting Rooms',
  //               onTap: () {
  //                 spacesController.changeCategory(
  //                   'Meeting Rooms',
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // ============================================================
  // CABIN TYPE FILTER
  // ============================================================

  // Widget _buildCabinTypeFilters() {
  //   return Obx(
  //         () {
  //       final selected =
  //           spacesController.selectedCabinType.value;
  //
  //       return Row(
  //         children: [
  //           Expanded(
  //             child: _filterChip(
  //               text: 'All Cabin Types',
  //               selected:
  //               selected == 'All Cabin Types',
  //               onTap: () {
  //                 spacesController.changeCabinType(
  //                   'All Cabin Types',
  //                 );
  //               },
  //             ),
  //           ),
  //
  //           const SizedBox(width: 7),
  //
  //           Expanded(
  //             child: _filterChip(
  //               text: 'Normal',
  //               selected:
  //               selected == 'Normal',
  //               onTap: () {
  //                 spacesController.changeCabinType(
  //                   'Normal',
  //                 );
  //               },
  //             ),
  //           ),
  //
  //           const SizedBox(width: 7),
  //
  //           Expanded(
  //             child: _filterChip(
  //               text: 'Exclusive',
  //               selected:
  //               selected == 'Exclusive',
  //               onTap: () {
  //                 spacesController.changeCabinType(
  //                   'Exclusive',
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _filterChip({
  //   required String text,
  //   required bool selected,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(20),
  //     child: Container(
  //       height: 32,
  //       alignment: Alignment.center,
  //       padding: const EdgeInsets.symmetric(
  //         horizontal: 10,
  //       ),
  //       decoration: BoxDecoration(
  //         color: selected
  //             ? AppColors.lightPrimary
  //             : AppColors.lightSurface,
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //           color: selected
  //               ? AppColors.lightPrimary
  //               : AppColors.lightBorder,
  //         ),
  //       ),
  //       child: Text(
  //         text,
  //         maxLines: 1,
  //         overflow: TextOverflow.ellipsis,
  //         style: TextStyle(
  //           color: selected
  //               ? Colors.white
  //               : AppColors.lightTextPrimary,
  //           fontSize: 8,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ============================================================
  // REAL SPACES API LIST
  // ============================================================

  // Widget _buildSpacesList() {
  //   return Obx(
  //         () {
  //       if (spacesController.isLoading.value &&
  //           spacesController.spaces.isEmpty) {
  //         return const Padding(
  //           padding: EdgeInsets.symmetric(
  //             vertical: 40,
  //           ),
  //           child: Center(
  //             child: CircularProgressIndicator(
  //               color: AppColors.lightPrimary,
  //             ),
  //           ),
  //         );
  //       }
  //
  //       if (spacesController
  //           .errorMessage.value !=
  //           null &&
  //           spacesController.spaces.isEmpty) {
  //         return _buildErrorState();
  //       }
  //
  //       final spaces =
  //           spacesController.filteredSpaces;
  //
  //       if (spaces.isEmpty) {
  //         return _buildEmptyState();
  //       }
  //
  //       return Column(
  //         children: spaces
  //             .map(
  //               (space) => Padding(
  //             padding:
  //             const EdgeInsets.only(
  //               bottom: 10,
  //             ),
  //             child:
  //             _buildDashboardSpaceCard(
  //               space,
  //             ),
  //           ),
  //         )
  //             .toList(),
  //       );
  //     },
  //   );
  // }

  // ============================================================
  // SPACE CARD
  // ============================================================

  // Widget _buildDashboardSpaceCard(
  //     SpaceModel space,
  //     ) {
  //   final imageUrl =
  //   space.images.isNotEmpty
  //       ? _buildMediaUrl(
  //     space.images.first,
  //   )
  //       : '';
  //
  //   final category =
  //   _getCategory(space);
  //
  //   return InkWell(
  //     onTap: () {
  //       Get.toNamed(
  //         AppRoutes.spaceDetails,
  //         arguments: space,
  //       );
  //     },
  //     borderRadius:
  //     BorderRadius.circular(13),
  //     child: Container(
  //       clipBehavior: Clip.antiAlias,
  //       decoration: BoxDecoration(
  //         color: AppColors.lightSurface,
  //         borderRadius:
  //         BorderRadius.circular(13),
  //         border: Border.all(
  //           color: AppColors.lightBorder,
  //         ),
  //       ),
  //       child: Row(
  //         crossAxisAlignment:
  //         CrossAxisAlignment.start,
  //         children: [
  //           SizedBox(
  //             width: 105,
  //             height: 120,
  //             child: Stack(
  //               fit: StackFit.expand,
  //               children: [
  //                 if (imageUrl.isNotEmpty)
  //                   Image.network(
  //                     imageUrl,
  //                     fit: BoxFit.cover,
  //                     errorBuilder:
  //                         (_, __, ___) {
  //                       return _spacePlaceholder();
  //                     },
  //                   )
  //                 else
  //                   _spacePlaceholder(),
  //
  //                 Positioned(
  //                   left: 6,
  //                   top: 6,
  //                   child: Container(
  //                     padding:
  //                     const EdgeInsets.symmetric(
  //                       horizontal: 6,
  //                       vertical: 3,
  //                     ),
  //                     decoration:
  //                     BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius:
  //                       BorderRadius.circular(
  //                         12,
  //                       ),
  //                     ),
  //                     child: Text(
  //                       category,
  //                       style: TextStyle(
  //                         color: space.isChamber
  //                             ? AppColors
  //                             .dashboardRed
  //                             : AppColors
  //                             .lightPrimary,
  //                         fontSize: 6,
  //                         fontWeight:
  //                         FontWeight.w700,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           Expanded(
  //             child: Padding(
  //               padding:
  //               const EdgeInsets.all(10),
  //               child: Column(
  //                 crossAxisAlignment:
  //                 CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     space.name,
  //                     maxLines: 1,
  //                     overflow:
  //                     TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                       color: AppColors
  //                           .lightTextPrimary,
  //                       fontSize: 11,
  //                       fontWeight:
  //                       FontWeight.w700,
  //                     ),
  //                   ),
  //
  //                   const SizedBox(height: 5),
  //
  //                   Row(
  //                     children: [
  //                       const Icon(
  //                         Icons
  //                             .location_on_outlined,
  //                         size: 11,
  //                         color: AppColors
  //                             .lightTextSecondary,
  //                       ),
  //
  //                       const SizedBox(width: 3),
  //
  //                       Expanded(
  //                         child: Text(
  //                           space.address,
  //                           maxLines: 1,
  //                           overflow:
  //                           TextOverflow
  //                               .ellipsis,
  //                           style:
  //                           const TextStyle(
  //                             color: AppColors
  //                                 .lightTextSecondary,
  //                             fontSize: 8,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //
  //                   const SizedBox(height: 4),
  //
  //                   Row(
  //                     children: [
  //                       const Icon(
  //                         Icons
  //                             .access_time_outlined,
  //                         size: 11,
  //                         color: AppColors
  //                             .lightTextSecondary,
  //                       ),
  //
  //                       const SizedBox(width: 3),
  //
  //                       Expanded(
  //                         child: Text(
  //                           space.timing,
  //                           style:
  //                           const TextStyle(
  //                             color: AppColors
  //                                 .lightTextSecondary,
  //                             fontSize: 8,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //
  //                   const SizedBox(height: 5),
  //
  //                   Row(
  //                     children: [
  //                       const Icon(
  //                         Icons
  //                             .person_outline_rounded,
  //                         size: 11,
  //                         color: AppColors
  //                             .lightTextSecondary,
  //                       ),
  //
  //                       const SizedBox(width: 3),
  //
  //                       Text(
  //                         '${space.seatCount} seats',
  //                         style:
  //                         const TextStyle(
  //                           color: AppColors
  //                               .lightTextSecondary,
  //                           fontSize: 8,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //
  //                   const SizedBox(height: 7),
  //
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           '${_formatPrice(space.price)}/hour',
  //                           style:
  //                           const TextStyle(
  //                             color: AppColors
  //                                 .lightPrimary,
  //                             fontSize: 11,
  //                             fontWeight:
  //                             FontWeight.w800,
  //                           ),
  //                         ),
  //                       ),
  //
  //                       Container(
  //                         height: 26,
  //                         padding:
  //                         const EdgeInsets
  //                             .symmetric(
  //                           horizontal: 9,
  //                         ),
  //                         alignment:
  //                         Alignment.center,
  //                         decoration:
  //                         BoxDecoration(
  //                           color: AppColors
  //                               .lightPrimary,
  //                           borderRadius:
  //                           BorderRadius
  //                               .circular(
  //                             7,
  //                           ),
  //                         ),
  //                         child: const Text(
  //                           'View',
  //                           style: TextStyle(
  //                             color:
  //                             Colors.white,
  //                             fontSize: 8,
  //                             fontWeight:
  //                             FontWeight.w700,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ============================================================
  // ERROR
  // ============================================================

  // Widget _buildErrorState() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(
  //       vertical: 30,
  //       horizontal: 20,
  //     ),
  //     decoration: BoxDecoration(
  //       color: AppColors.lightSurface,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: AppColors.lightBorder,
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         const Icon(
  //           Icons.cloud_off_outlined,
  //           color: AppColors.dashboardRed,
  //           size: 30,
  //         ),
  //
  //         const SizedBox(height: 8),
  //
  //         const Text(
  //           'Unable to load spaces',
  //           style: TextStyle(
  //             color: AppColors.lightTextPrimary,
  //             fontSize: 11,
  //             fontWeight: FontWeight.w700,
  //           ),
  //         ),
  //
  //         const SizedBox(height: 5),
  //
  //         Text(
  //           spacesController.errorMessage.value ??
  //               'Please try again.',
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(
  //             color: AppColors.lightTextSecondary,
  //             fontSize: 8,
  //           ),
  //         ),
  //
  //         const SizedBox(height: 12),
  //
  //         SizedBox(
  //           height: 30,
  //           child: ElevatedButton(
  //             onPressed:
  //             spacesController.getSpaces,
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor:
  //               AppColors.lightPrimary,
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text(
  //               'Retry',
  //               style: TextStyle(
  //                 fontSize: 8,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 30,
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
            color:
            AppColors.lightTextSecondary,
            size: 30,
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
              color:
              AppColors.lightTextSecondary,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _spacePlaceholder() {
    return Container(
      color: AppColors.softPurple,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.lightPrimary,
        size: 28,
      ),
    );
  }

  String _buildMediaUrl(
      String path,
      ) {
    final value = path.trim();

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    final normalized =
    value.replaceAll(
      '\\',
      '/',
    );

    return 'https://spaceapi.iryax.com/$normalized';
  }

  String _formatPrice(
      double price,
      ) {
    if (price % 1 == 0) {
      return '₹${price.toInt()}';
    }

    return '₹${price.toStringAsFixed(2)}';
  }

  String _getCategory(
      SpaceModel space,
      ) {
    if (space.isChamber) {
      return 'Medical';
    }

    if (space.isCafe) {
      return 'Cafe';
    }

    if (space.isExclusive) {
      return 'Private';
    }

    return 'Co-Working';
  }
}