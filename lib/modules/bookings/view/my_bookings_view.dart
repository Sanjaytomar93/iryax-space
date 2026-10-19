import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/model/site_visit_model.dart';

class MyBookingsView extends GetView<BookingsController> {
  const MyBookingsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.lightBackground,
      child: Obx(
            () => ListView(
          padding: const EdgeInsets.fromLTRB(
            14,
            14,
            14,
            90,
          ),
          children: [
            _header(),

            const SizedBox(height: 12),

            _bookingTabs(),

            const SizedBox(height: 12),

            if (controller.selectedBookingTab.value == 0)
              _spaceBookings()
            else
              _siteVisits(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final isBookings =
        controller.selectedBookingTab.value == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'My ',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: isBookings
                    ? 'Space Bookings'
                    : 'Site Visits',
                style: const TextStyle(
                  color: AppColors.lightPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isBookings
              ? 'Manage all your workspace bookings'
              : 'Manage all your site visit appointments',
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _bookingTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tab(
              index: 0,
              title: 'Space Bookings',
              subtitle: 'Your workspace bookings',
            ),
          ),
          Expanded(
            child: _tab(
              index: 1,
              title: 'Site Visits',
              subtitle: 'Your site visit appointments',
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final selected =
        controller.selectedBookingTab.value == index;

    return InkWell(
      onTap: () {
        controller.changeBookingTab(index);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightPrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : AppColors.lightTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : AppColors.lightTextSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w400
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spaceBookings() {
    if (controller.isLoadingBookings.value) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.bookingError.value != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 34,
              color: AppColors.dashboardRed,
            ),
            const SizedBox(height: 10),
            Text(
              controller.bookingError.value!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: controller.loadBookings,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      );
    }

    if (controller.bookings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 36,
              color: AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 10),
            const Text(
              'No bookings yet',
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your workspace bookings will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 8,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.loadBookings,
              icon: const Icon(
                Icons.refresh,
                size: 14,
              ),
              label: const Text(
                'Refresh',
              ),
            ),
          ],
        ),
      );
    }


    final filtered =
        controller.filteredBookings;

    return Column(
      children: [
        _bookingStats(),

        const SizedBox(height: 12),

        _bookingFilters(),

        // _filters(
        //   searchHint: 'Search bookings...',
        //   showPayment: true,
        // ),

        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Showing ${filtered.length} of ${controller.bookings.length} bookings',            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 9,
            ),
          ),
        ),

        const SizedBox(height: 12),

        _sectionHeader(
          title: 'Space Bookings',
          count: filtered.length,
        ),

        const SizedBox(height: 8),

        ...filtered.map(
              (booking) => Padding(
            padding: const EdgeInsets.only(
              bottom: 9,
            ),
            child: _bookingCard(
              booking,
            ),
          ),
        ),
      ],
    );
  }


  Widget _bookingStats() {
    return Obx(
          () {
            final selectedStat =
                controller.selectedBookingStat.value;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'TOTAL',
                    '${controller.bookings.length}',
                    'all reservations',
                    Icons.inbox_outlined,
                    AppColors.lightPrimary,
                    AppColors.softPurple,
                    selected:
                    selectedStat == 'All',
                    onTap: () {
                      _applyBookingStatFilter(
                        'All Status',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _statCard(
                    'PENDING',
                    '${controller.bookingCount(BookingStatus.pending)}',
                    'awaiting confirmation',
                    Icons.access_time_rounded,
                    AppColors.dashboardOrange,
                    AppColors.softOrange,
                    selected:
                    selectedStat == 'Pending',
                    onTap: () {
                      _applyBookingStatFilter(
                        'Pending',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'ACTIVE & CONFIRMED',
                    '${controller.bookingCount(BookingStatus.active) + controller.bookingCount(BookingStatus.confirmed)}',
                    'active & confirmed',
                    Icons.home_outlined,
                    AppColors.dashboardGreen,
                    AppColors.softGreen,
                    selected:
                    selectedStat ==
                        'Active & Confirmed',
                    onTap: () {
                      controller
                          .clearDashboardFilters();

                      controller.changeBookingStat(
                        'Active & Confirmed',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _statCard(
                    'COMPLETED',
                    '${controller.bookingCount(BookingStatus.completed)}',
                    'completed reservations',
                    Icons.check_circle_outline,
                    AppColors.dashboardPurple,
                    AppColors.softPurple,
                    selected:
                    selectedStat == 'Completed',
                    onTap: () {
                      _applyBookingStatFilter(
                        'Completed',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'CANCELLED',
                    '${controller.bookingCount(BookingStatus.cancelled)}',
                    'cancelled reservations',
                    Icons.cancel_outlined,
                    AppColors.dashboardRed,
                    AppColors.softRed,
                    selected:
                    selectedStat == 'Cancelled',
                    onTap: () {
                      _applyBookingStatFilter(
                        'Cancelled',
                      );
                    },
                  ),
                ),

                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  Widget _siteVisits() {
    if (controller.isLoadingVisits.value) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.visitError.value != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 34,
              color: AppColors.dashboardRed,
            ),
            const SizedBox(height: 10),
            Text(
              controller.visitError.value!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: controller.loadSiteVisits,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      );
    }

    if (controller.siteVisits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 36,
              color: AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 10),
            const Text(
              'No site visits yet',
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your site visit appointments will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.loadSiteVisits,
              icon: const Icon(
                Icons.refresh,
                size: 14,
              ),
              label: const Text(
                'Refresh',
              ),
            ),
          ],
        ),
      );
    }

    final filtered =
        controller.filteredSiteVisits;

    return Column(
      children: [
        _siteVisitStats(),

        const SizedBox(height: 12),

        _siteVisitFilters(),

        // _filters(
        //   searchHint: 'Search visits...',
        //   showPayment: false,
        // ),

        const SizedBox(height: 7),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Showing ${filtered.length} of ${controller.siteVisits.length} site visits',            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 9,
            ),
          ),
        ),

        const SizedBox(height: 12),

        _sectionHeader(
          title: 'Site Visits',
          count: filtered.length,
        ),

        const SizedBox(height: 8),

        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 30,
            ),
            child: Center(
              child: Text(
                'No site visits match your filters.',
                style: TextStyle(
                  color:
                  AppColors.lightTextSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          )
        else
          ...filtered.map(
                (visit) => Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: _siteVisitCard(
                visit,
              ),
            ),
          ),

        const SizedBox(height: 18),

        const Text(
          '© IRYAX SPACE — All Rights Reserved',
          style: TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }


  void _applyBookingStatFilter(
      String status,
      ) {
    controller.clearDashboardFilters();

    if (status != 'All Status') {
      controller.changeStatus(
        status,
      );
    }
  }

  void _applySiteVisitStatFilter(
      String status,
      ) {
    controller.clearSiteVisitFilters();

    if (status != 'All Status') {
      controller.changeVisitStatus(
        status,
      );
    }
  }



  Widget _siteVisitStats() {
    return Obx(
          () {
        final selectedStatus =
            controller
                .selectedVisitStatus
                .value;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'TOTAL',
                    '${controller.siteVisits.length}',
                    'all visits',
                    Icons.inbox_outlined,
                    AppColors.lightPrimary,
                    AppColors.softPurple,
                    selected:
                    selectedStatus ==
                        'All Status',
                    onTap: () {
                      _applySiteVisitStatFilter(
                        'All Status',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _statCard(
                    'PENDING',
                    '${controller.siteVisitCount(SiteVisitStatus.pending)}',
                    'awaiting confirmation',
                    Icons.access_time_rounded,
                    AppColors.dashboardOrange,
                    AppColors.softOrange,
                    selected:
                    selectedStatus ==
                        'Pending',
                    onTap: () {
                      _applySiteVisitStatFilter(
                        'Pending',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'CONFIRMED',
                    '${controller.siteVisitCount(SiteVisitStatus.confirmed)}',
                    'confirmed visits',
                    Icons.check_circle_outline,
                    AppColors.dashboardBlue,
                    AppColors.softBlue,
                    selected:
                    selectedStatus ==
                        'Confirmed',
                    onTap: () {
                      _applySiteVisitStatFilter(
                        'Confirmed',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _statCard(
                    'COMPLETED',
                    '${controller.siteVisitCount(SiteVisitStatus.completed)}',
                    'completed visits',
                    Icons.calendar_month_outlined,
                    AppColors.dashboardPurple,
                    AppColors.softPurple,
                    selected:
                    selectedStatus ==
                        'Completed',
                    onTap: () {
                      _applySiteVisitStatFilter(
                        'Completed',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'CANCELLED',
                    '${controller.siteVisitCount(SiteVisitStatus.cancelled)}',
                    'cancelled visits',
                    Icons.cancel_outlined,
                    AppColors.dashboardRed,
                    AppColors.softRed,
                    selected:
                    selectedStatus ==
                        'Cancelled',
                    onTap: () {
                      _applySiteVisitStatFilter(
                        'Cancelled',
                      );
                    },
                  ),
                ),

                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  Widget _statCard(
      String title,
      String value,
      String subtitle,
      IconData icon,
      Color iconColor,
      Color background, {
        required bool selected,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding:
        const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? background
              : AppColors.lightSurface,
          borderRadius:
          BorderRadius.circular(11),
          border: Border.all(
            color: selected
                ? iconColor
                : AppColors.lightBorder,
            width: selected ? 1.4 : 1,
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
                      fontSize: 9.5,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius:
                    BorderRadius.circular(
                      7,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              value,
              style: const TextStyle(
                color:
                AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors
                    .lightTextSecondary,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingFilters() {
    return Obx(
          () => Column(
        children: [
          SizedBox(
            height: 36,
            child: TextField(
              controller:
              controller.searchController,
              onChanged:
              controller.updateSearch,
              style: const TextStyle(
                color:
                AppColors.lightTextPrimary,
                fontSize: 10,
              ),
              decoration: InputDecoration(
                hintText:
                'Search bookings...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 14,
                ),
                filled: true,
                fillColor:
                AppColors.lightSurface,
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 9,
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(
                    color:
                    AppColors.lightBorder,
                  ),
                ),
                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
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

          _bookingDateField(),

          const SizedBox(height: 7),

          Row(
            children: [
              Expanded(
                child: _bookingDropdown(
                  value:
                  controller
                      .selectedStatus.value,
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
                      controller.changeStatus(
                        value,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _bookingDropdown(
                  value:
                  controller
                      .selectedType.value,
                  items: const [
                    'All Types',
                    'Co-Working Space',
                    'Medical Chamber',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeType(
                        value,
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          _bookingDropdown(
            value:
            controller
                .selectedPaymentStatus
                .value,
            items: const [
              'Payment Status',
              'Paid',
              'Pending',
            ],
            onChanged: (value) {
              if (value != null) {
                controller
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


  Widget _bookingDateField() {
    return Obx(
          () {
        final selected =
            controller.selectedBookingDate.value;

        final text = selected == null
            ? 'mm/dd/yyyy'
            : '${selected.month.toString().padLeft(2, '0')}/'
            '${selected.day.toString().padLeft(2, '0')}/'
            '${selected.year}';

        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate:
              selected ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );

            if (picked != null) {
              controller.changeBookingDate(
                picked,
              );
            }
          },
          borderRadius:
          BorderRadius.circular(8),
          child: Container(
            height: 36,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius:
              BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color:
                  AppColors.lightTextSecondary,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: AppColors
                          .lightTextSecondary,
                      fontSize: 9,
                    ),
                  ),
                ),

                if (selected != null)
                  InkWell(
                    onTap: () {
                      controller.changeBookingDate(
                        null,
                      );
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: AppColors
                          .lightTextSecondary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _bookingDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?>
    onChanged,
  }) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius:
        BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor:
          AppColors.lightSurface,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 13,
            color:
            AppColors.lightTextSecondary,
          ),
          style: const TextStyle(
            color:
            AppColors.lightTextPrimary,
            fontSize: 9,
          ),
          items: items
              .map(
                (item) =>
                DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow:
                    TextOverflow.ellipsis,
                  ),
                ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }


  Widget _siteVisitFilters() {
    return Obx(
          () => Column(
        children: [
          SizedBox(
            height: 36,
            child: TextField(
              onChanged: controller.updateSiteVisitSearch,
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 10,
              ),
              decoration: InputDecoration(
                hintText: 'Search visits...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 14,
                ),
                filled: true,
                fillColor: AppColors.lightSurface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 9,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 7),

          _siteVisitDateField(),

          const SizedBox(height: 7),

          Row(
            children: [
              Expanded(
                child: _bookingDropdown(
                  value: controller.selectedVisitStatus.value,
                  items: const [
                    'All Status',
                    'Pending',
                    'Confirmed',
                    'Completed',
                    'Cancelled',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeVisitStatus(
                        value,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _bookingDropdown(
                  value: controller.selectedVisitType.value,
                  items: const [
                    'All Types',
                    'Co-Working Space',
                    'Medical Chamber',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeVisitType(
                        value,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _siteVisitDateField() {
    return Obx(
          () {
        final selected =
            controller.selectedVisitDate.value;

        final text = selected == null
            ? 'mm/dd/yyyy'
            : '${selected.month.toString().padLeft(2, '0')}/'
            '${selected.day.toString().padLeft(2, '0')}/'
            '${selected.year}';

        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate: selected ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );

            if (picked != null) {
              controller.changeVisitDate(
                picked,
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 36,
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
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: AppColors.lightTextSecondary,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 9,
                    ),
                  ),
                ),

                if (selected != null)
                  InkWell(
                    onTap: () {
                      controller.changeVisitDate(
                        null,
                      );
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }



  // Widget _inputBox(
  //     String hint,
  //     IconData icon,
  //     ) {
  //   return Container(
  //     height: 36,
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 9,
  //     ),
  //     decoration: BoxDecoration(
  //       color: AppColors.lightSurface,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(
  //         color: AppColors.lightBorder,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           icon,
  //           size: 12,
  //           color: AppColors.lightTextSecondary,
  //         ),
  //         const SizedBox(width: 7),
  //         Text(
  //           hint,
  //           style: const TextStyle(
  //             color: AppColors.lightTextSecondary,
  //             fontSize: 7,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _dropdownBox(String text) {
  //   return Container(
  //     height: 34,
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 9,
  //     ),
  //     decoration: BoxDecoration(
  //       color: AppColors.lightSurface,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(
  //         color: AppColors.lightBorder,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Text(
  //             text,
  //             style: const TextStyle(
  //               color: AppColors.lightTextPrimary,
  //               fontSize: 7,
  //             ),
  //           ),
  //         ),
  //         const Icon(
  //           Icons.keyboard_arrow_down_rounded,
  //           size: 13,
  //           color: AppColors.lightTextSecondary,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _sectionHeader({
    required String title,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 12,
            color: AppColors.lightPrimary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(
      BookingModel booking,
      ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.spaceName,
                  style: const TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _numberBadge(booking.id),
            ],
          ),

          const SizedBox(height: 2),

          _smallInfo(
            Icons.location_on_outlined,
            booking.location,
          ),

          const SizedBox(height: 5),

          _spaceTypeChip(
            booking.spaceType,
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _dateBox(
                  'START',
                  booking.startDate,
                  booking.startTime,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _dateBox(
                  'END',
                  booking.endDate,
                  booking.endTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Wrap(
            spacing: 5,
            children: [
              _miniChip(booking.duration),
              _miniChip(booking.days),
              _miniChip('${booking.seats} seats'),
            ],
          ),

          const SizedBox(height: 6),

          Wrap(
            spacing: 5,
            children: [
              _bookingStatusChip(
                booking.status,
              ),
              _paymentModeChip(
                booking.paymentMode,
              ),
              _paymentChip(
                booking.paymentStatus,
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Divider(
            height: 1,
            color: AppColors.lightBorder,
          ),

          const SizedBox(height: 7),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  booking.amount,
                  style: const TextStyle(
                    color: AppColors.lightPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CREATED',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    booking.createdAt,
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              Expanded(
                child: _actionButton(
                  Icons.visibility_outlined,
                  AppColors.lightPrimary,
                      () => controller.openBookingDetails(
                    booking,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: _actionButton(
                  Icons.download_outlined,
                  AppColors.dashboardGreen,
                      () {},
                ),
              ),

              if (booking.status !=
                  BookingStatus.cancelled &&
                  booking.status !=
                      BookingStatus.completed) ...[
                const SizedBox(width: 5),
                Expanded(
                  child: _actionButton(
                    Icons.sync_alt_rounded,
                    AppColors.dashboardOrange,
                        () => controller.openReplaceSpace(
                      booking,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _actionButton(
                    Icons.close_rounded,
                    AppColors.dashboardRed,
                        () => controller.openCancelBooking(
                      booking,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _siteVisitCard(
      SiteVisitModel visit,
      ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  visit.spaceName,
                  style: const TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _numberBadge(visit.id),
            ],
          ),

          const SizedBox(height: 3),

          _smallInfo(
            Icons.location_on_outlined,
            visit.location,
          ),

          const SizedBox(height: 6),

          _spaceTypeChip(
            visit.spaceType,
          ),

          const SizedBox(height: 10),

          const Divider(
            height: 1,
            color: AppColors.lightBorder,
          ),

          const SizedBox(height: 10),

          _visitRow(
            'Visit date & time',
            visit.visitDate,
            visit.visitTime,
          ),

          const SizedBox(height: 8),

          _visitRow(
            'Visitor',
            visit.visitorName,
            visit.visitorMobile,
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _visitStatusChip(
                visit.status,
              ),
            ],
          ),

          const SizedBox(height: 8),

          _visitRow(
            'Created at',
            visit.createdAt,
            '',
          ),

          const SizedBox(height: 9),

          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: () {
                controller.openSiteVisitDetails(
                  visit,
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                side: const BorderSide(
                  color: AppColors.lightBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              icon: const Icon(
                Icons.visibility_outlined,
                size: 11,
                color: AppColors.lightPrimary,
              ),
              label: const Text(
                'View Details',
                style: TextStyle(
                  color: AppColors.lightPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox(
      String title,
      String date,
      String time,
      ) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            date,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return SizedBox(
      height: 28,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(
            color: AppColors.lightBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Icon(
          icon,
          size: 11,
          color: color,
        ),
      ),
    );
  }

  Widget _smallInfo(
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
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _numberBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$value',
        style: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 7.5,
        ),
      ),
    );
  }

  Widget _spaceTypeChip(String type) {
    final medical =
    type.toLowerCase().contains('medical');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: medical
            ? AppColors.softGreen
            : AppColors.softBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: medical
              ? AppColors.dashboardGreen
              : AppColors.dashboardBlue,
          fontSize: 7.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 7.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _bookingStatusChip(
      BookingStatus status,
      ) {
    Color color;
    Color background;

    switch (status) {
      case BookingStatus.pending:
        color = AppColors.dashboardOrange;
        background = AppColors.softOrange;
        break;
      case BookingStatus.confirmed:
        color = AppColors.dashboardBlue;
        background = AppColors.softBlue;
        break;
      case BookingStatus.active:
        color = AppColors.dashboardGreen;
        background = AppColors.softGreen;
        break;
      case BookingStatus.completed:
        color = AppColors.dashboardPurple;
        background = AppColors.softPurple;
        break;
      case BookingStatus.cancelled:
        color = AppColors.dashboardRed;
        background = AppColors.softRed;
        break;
    }

    return _tag(
      controller.bookingStatusText(status),
      color,
      background,
    );
  }

  Widget _paymentChip(
      PaymentStatus status,
      ) {
    return _tag(
      controller.paymentStatusText(status),
      status == PaymentStatus.paid
          ? AppColors.dashboardGreen
          : AppColors.dashboardOrange,
      status == PaymentStatus.paid
          ? AppColors.softGreen
          : AppColors.softOrange,
    );
  }

  Widget _paymentModeChip(
      PaymentMode mode,
      ) {
    return _tag(
      controller.paymentModeText(mode),
      mode == PaymentMode.cash
          ? AppColors.dashboardOrange
          : AppColors.dashboardBlue,
      mode == PaymentMode.cash
          ? AppColors.softOrange
          : AppColors.softBlue,
    );
  }

  Widget _visitStatusChip(
      SiteVisitStatus status,
      ) {
    Color color;
    Color bg;

    switch (status) {
      case SiteVisitStatus.pending:
        color = AppColors.dashboardOrange;
        bg = AppColors.softOrange;
        break;
      case SiteVisitStatus.confirmed:
        color = AppColors.dashboardGreen;
        bg = AppColors.softGreen;
        break;
      case SiteVisitStatus.completed:
        color = AppColors.dashboardBlue;
        bg = AppColors.softBlue;
        break;
      case SiteVisitStatus.cancelled:
        color = AppColors.dashboardRed;
        bg = AppColors.softRed;
        break;
    }

    return _tag(
      controller.siteVisitStatusText(status),
      color,
      bg,
    );
  }

  Widget _tag(
      String text,
      Color color,
      Color background,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 7.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _visitRow(
      String label,
      String mainValue,
      String secondary,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              mainValue,
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (secondary.isNotEmpty)
              Text(
                secondary,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 8,
                ),
              ),
          ],
        ),
      ],
    );
  }
}