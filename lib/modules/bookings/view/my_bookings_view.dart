import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/model/site_visit_model.dart';
import 'package:iryax_spaces/modules/bookings/service/bookings_export_service.dart';
import 'package:iryax_spaces/modules/bookings/service/invoice_pdf_service.dart';
import 'package:iryax_spaces/modules/bookings/widget/space_booking_details_dialog.dart';

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
              _spaceBookings(context)
            else
              _siteVisits(context),
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
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: isBookings
                    ? 'Space Bookings'
                    : 'Site Visits',
                style: const TextStyle(
                  color: AppColors.lightPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isBookings
              ? 'Manage all your workspace bookings'
              : 'Manage all your site visit appointments',
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
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

  Widget _spaceBookings(BuildContext context) {
    if (controller.isLoadingBookings.value) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: BookingListShimmer(),
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

        _bookingFilters(context),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Showing ${filtered.length} of ${controller.bookings.length} bookings',
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 12,
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

            _statCard(
              'CANCELLED',
              '${controller.bookingCount(BookingStatus.cancelled)}',
              'cancelled reservations',
              Icons.cancel_outlined,
              AppColors.dashboardRed,
              AppColors.softRed,
              selected: selectedStat == 'Cancelled',
              onTap: () {
                _applyBookingStatFilter('Cancelled');
              },
            ),
          ],
        );
      },
    );
  }


  Widget _siteVisits(BuildContext context) {
    if (controller.isLoadingVisits.value) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: BookingListShimmer(),
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

        _siteVisitFilters(context),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Showing ${filtered.length} of ${controller.siteVisits.length} site visits',
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 12,
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

            _statCard(
              'CANCELLED',
              '${controller.siteVisitCount(SiteVisitStatus.cancelled)}',
              'cancelled visits',
              Icons.cancel_outlined,
              AppColors.dashboardRed,
              AppColors.softRed,
              selected: selectedStatus == 'Cancelled',
              onTap: () {
                _applySiteVisitStatFilter('Cancelled');
              },
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
    Color iconBg, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? iconColor : AppColors.lightBorder,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? iconColor
                          : AppColors.lightTextSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, color: iconColor, size: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42,
          child: TextField(
            autofocus: false,
            controller: controller.searchController,
            onChanged: controller.updateSearch,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Search bookings...',
              hintStyle: const TextStyle(
                color: AppColors.lightHint,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: AppColors.lightTextSecondary,
              ),
              filled: true,
              fillColor: AppColors.lightSurface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightPrimary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final status = controller.selectedStatus.value;
          final payment = controller.selectedPaymentStatus.value;
          final type = controller.selectedType.value;
          final date = controller.selectedBookingDate.value;
          final hasFilters =
              controller.searchQuery.value.isNotEmpty ||
              status != 'All Status' ||
              payment != 'Payment Status' ||
              type != 'All Types' ||
              date != null;

          final dateLabel = date == null
              ? 'Date'
              : '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}';

          return Column(
            children: [
              SizedBox(
                height: 42,
                child: Row(
                  children: [
                    Expanded(
                      child: _filterChip(
                        label: dateLabel,
                        icon: Icons.calendar_today_outlined,
                        selected: date != null,
                        expanded: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            controller.changeBookingDate(picked);
                          }
                        },
                        onClear: date != null
                            ? () => controller.changeBookingDate(null)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _filterChip(
                        label: status == 'All Status' ? 'Status' : status,
                        icon: Icons.flag_outlined,
                        selected: status != 'All Status',
                        expanded: true,
                        onTap: () => _showFilterSheet(
                          context: context,
                          title: 'Status',
                          items: const [
                            'All Status',
                            'Pending',
                            'Confirmed',
                            'Active',
                            'Completed',
                            'Cancelled',
                          ],
                          selected: status,
                          onSelect: controller.changeStatus,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _filterChip(
                        label:
                            payment == 'Payment Status' ? 'Payment' : payment,
                        icon: Icons.payments_outlined,
                        selected: payment != 'Payment Status',
                        expanded: true,
                        onTap: () => _showFilterSheet(
                          context: context,
                          title: 'Payment Status',
                          items: const [
                            'Payment Status',
                            'Pending',
                            'Paid',
                            'Failed',
                            'Refunded',
                          ],
                          selected: payment,
                          onSelect: controller.changePaymentStatus,
                          labelOf: (v) => v == 'Payment Status' ? 'All' : v,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _filterChip(
                        label: type == 'All Types' ? 'Type' : type,
                        icon: Icons.category_outlined,
                        selected: type != 'All Types',
                        expanded: true,
                        onTap: () => _showFilterSheet(
                          context: context,
                          title: 'Space Type',
                          items: const [
                            'All Types',
                            'Co-Working Space',
                            'Meeting Room',
                            'Medical Chamber',
                            'Cafe & Dining',
                            'Private Office',
                          ],
                          selected: type,
                          onSelect: controller.changeType,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => _downloadIconButton(
                        isLoading:
                            BookingsExportService.isExportingBookings.value,
                        onTap: () {
                          BookingsExportService.downloadCsv(
                            controller: controller,
                            bookings: controller.filteredBookings,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: _filterChip(
                    label: 'Clear',
                    icon: Icons.close_rounded,
                    selected: false,
                    accent: true,
                    onTap: controller.clearDashboardFilters,
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _downloadIconButton({
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.lightPrimary,
                    ),
                  ),
                )
              : const Icon(
                  Icons.download_outlined,
                  size: 18,
                  color: AppColors.lightTextPrimary,
                ),
        ),
      ),
    );
  }

  Widget _siteVisitFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42,
          child: TextField(
            autofocus: false,
            onChanged: controller.updateSiteVisitSearch,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Search visits...',
              hintStyle: const TextStyle(
                color: AppColors.lightHint,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: AppColors.lightTextSecondary,
              ),
              filled: true,
              fillColor: AppColors.lightSurface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightPrimary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final status = controller.selectedVisitStatus.value;
          final type = controller.selectedVisitType.value;
          final date = controller.selectedVisitDate.value;
          final hasFilters =
              controller.siteVisitSearchQuery.value.isNotEmpty ||
              status != 'All Status' ||
              type != 'All Types' ||
              date != null;

          final dateLabel = date == null
              ? 'Date'
              : '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}';

          return Column(
            children: [
              SizedBox(
                height: 42,
                child: Row(
                  children: [
                    Expanded(
                      child: _filterChip(
                        label: dateLabel,
                        icon: Icons.calendar_today_outlined,
                        selected: date != null,
                        expanded: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            controller.changeVisitDate(picked);
                          }
                        },
                        onClear: date != null
                            ? () => controller.changeVisitDate(null)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _filterChip(
                        label: status == 'All Status' ? 'Status' : status,
                        icon: Icons.flag_outlined,
                        selected: status != 'All Status',
                        expanded: true,
                        onTap: () => _showFilterSheet(
                          context: context,
                          title: 'Status',
                          items: const [
                            'All Status',
                            'Pending',
                            'Confirmed',
                            'Completed',
                            'Cancelled',
                          ],
                          selected: status,
                          onSelect: controller.changeVisitStatus,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _filterChip(
                        label: type == 'All Types' ? 'Type' : type,
                        icon: Icons.category_outlined,
                        selected: type != 'All Types',
                        expanded: true,
                        onTap: () => _showFilterSheet(
                          context: context,
                          title: 'Space Type',
                          items: const [
                            'All Types',
                            'Co-Working Space',
                            'Meeting Room',
                            'Medical Chamber',
                            'Cafe & Dining',
                            'Private Office',
                          ],
                          selected: type,
                          onSelect: controller.changeVisitType,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => _downloadIconButton(
                        isLoading:
                            BookingsExportService.isExportingSiteVisits.value,
                        onTap: () {
                          BookingsExportService.downloadSiteVisitsCsv(
                            controller: controller,
                            visits: controller.filteredSiteVisits,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: _filterChip(
                    label: 'Clear',
                    icon: Icons.close_rounded,
                    selected: false,
                    accent: true,
                    onTap: controller.clearSiteVisitFilters,
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    VoidCallback? onClear,
    bool accent = false,
    bool expanded = false,
  }) {
    final bg = accent
        ? AppColors.softPurple
        : selected
            ? AppColors.lightPrimary
            : AppColors.lightSurface;
    final fg = accent
        ? AppColors.lightPrimary
        : selected
            ? Colors.white
            : AppColors.lightTextPrimary;
    final border = accent
        ? AppColors.lightPrimary.withValues(alpha: 0.2)
        : selected
            ? AppColors.lightPrimary
            : AppColors.lightBorder;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: expanded ? 13 : 16, color: fg),
        SizedBox(width: expanded ? 3 : 6),
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: expanded ? 11 : 12,
            color: fg,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
        if (onClear != null) ...[
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: expanded ? 12 : 14, color: fg),
          ),
        ] else if (!accent && !selected) ...[
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: expanded ? 14 : 16,
            color: fg,
          ),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          width: expanded ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: expanded ? 6 : 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: expanded
              ? FittedBox(fit: BoxFit.scaleDown, child: content)
              : content,
        ),
      ),
    );
  }

  void _showFilterSheet({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelect,
    String Function(String)? labelOf,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...items.map((item) {
                  final isSelected = item == selected;
                  final label = labelOf?.call(item) ?? item;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? AppColors.lightPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.lightPrimary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onSelect(item);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader({
    required String title,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 16,
            color: AppColors.lightPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.lightBorder),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _numberBadge(booking.id),
            ],
          ),
          const SizedBox(height: 3),
          _smallInfo(Icons.location_on_outlined, booking.location),
          const SizedBox(height: 6),
          _spaceTypeChip(booking.spaceType),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _dateBox('START', booking.startDate, booking.startTime),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _dateBox('END', booking.endDate, booking.endTime),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              _miniChip(booking.duration),
              _miniChip(booking.days),
              _miniChip('${booking.seats} seats'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bookingStatusChip(booking.status),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _paymentModeChip(booking.paymentMode),
                  const SizedBox(width: 6),
                  _paymentChip(booking.paymentStatus),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.lightBorder),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    booking.createdAt,
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 10,
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
                  () {
                    Get.dialog(
                      SpaceBookingDetailsDialog(booking: booking),
                    );
                  },
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _actionButton(
                  Icons.download_outlined,
                  AppColors.dashboardGreen,
                  () => InvoicePdfService.downloadAndShare(booking),
                ),
              ),
              if (booking.status != BookingStatus.cancelled &&
                  booking.status != BookingStatus.completed) ...[
                const SizedBox(width: 5),
                Expanded(
                  child: _actionButton(
                    Icons.sync_rounded,
                    AppColors.dashboardOrange,
                    () => controller.openReplaceSpace(booking),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _actionButton(
                    Icons.close_rounded,
                    const Color(0xFFDC2626),
                    () => controller.openCancelBooking(booking),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _siteVisitCard(SiteVisitModel visit) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.lightBorder),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _numberBadge(visit.id),
            ],
          ),
          const SizedBox(height: 3),
          _smallInfo(Icons.location_on_outlined, visit.location),
          const SizedBox(height: 6),
          _spaceTypeChip(visit.spaceType),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.lightBorder),
          const SizedBox(height: 10),
          _visitRow('Visit date & time', visit.visitDate, visit.visitTime),
          const SizedBox(height: 8),
          _visitRow('Visitor', visit.visitorName, visit.visitorMobile),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _visitStatusChip(visit.status),
            ],
          ),
          const SizedBox(height: 8),
          _visitRow('Created at', visit.createdAt, ''),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: OutlinedButton.icon(
              onPressed: () => controller.openSiteVisitDetails(visit),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                side: const BorderSide(color: AppColors.lightBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              icon: const Icon(
                Icons.visibility_outlined,
                size: 14,
                color: AppColors.lightPrimary,
              ),
              label: const Text(
                'View Details',
                style: TextStyle(
                  color: AppColors.lightPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String title, String date, String time) {
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
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            date,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 10,
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
      height: 30,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  Widget _smallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.lightTextSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _numberBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$value',
        style: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _spaceTypeChip(String type) {
    final medical = type.toLowerCase().contains('medical');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: medical ? AppColors.softGreen : AppColors.softBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: medical ? AppColors.dashboardGreen : AppColors.dashboardBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 10,
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
      case BookingStatus.confirmed:
        color = const Color(0xFF047857);
        background = const Color(0xFFD1FAE5);
        break;
      case BookingStatus.active:
        color = const Color(0xFF15803D);
        background = const Color(0xFFDCFCE7);
        break;
      case BookingStatus.pending:
        color = const Color(0xFFB45309);
        background = const Color(0xFFFEF3C7);
        break;
      case BookingStatus.completed:
        color = const Color(0xFF7E22CE);
        background = const Color(0xFFF3E8FF);
        break;
      case BookingStatus.cancelled:
        color = const Color(0xFFB91C1C);
        background = const Color(0xFFFEE2E2);
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
    late final Color text;
    late final Color bg;

    switch (status) {
      case PaymentStatus.pending:
        text = const Color(0xFF854D0E);
        bg = const Color(0xFFFEF9C3);
        break;
      case PaymentStatus.paid:
        text = const Color(0xFF047857);
        bg = const Color(0xFFD1FAE5);
        break;
      case PaymentStatus.failed:
        text = const Color(0xFFB91C1C);
        bg = const Color(0xFFFEE2E2);
        break;
      case PaymentStatus.refunded:
        text = const Color(0xFF1D4ED8);
        bg = const Color(0xFFDBEAFE);
        break;
    }

    return _tag(
      controller.paymentStatusText(status),
      text,
      bg,
    );
  }

  Widget _paymentModeChip(
    PaymentMode mode,
  ) {
    final isCash = mode == PaymentMode.cash;
    return _tag(
      controller.paymentModeText(mode),
      isCash ? const Color(0xFFC2410C) : const Color(0xFF1D4ED8),
      isCash ? const Color(0xFFFFEDD5) : const Color(0xFFDBEAFE),
    );
  }

  Widget _visitStatusChip(
    SiteVisitStatus status,
  ) {
    Color color;
    Color bg;

    switch (status) {
      case SiteVisitStatus.pending:
        color = const Color(0xFFB45309);
        bg = const Color(0xFFFEF3C7);
        break;
      case SiteVisitStatus.confirmed:
        color = const Color(0xFF047857);
        bg = const Color(0xFFD1FAE5);
        break;
      case SiteVisitStatus.completed:
        color = const Color(0xFF1D4ED8);
        bg = const Color(0xFFDBEAFE);
        break;
      case SiteVisitStatus.cancelled:
        color = const Color(0xFFB91C1C);
        bg = const Color(0xFFFEE2E2);
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
              fontSize: 11,
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
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (secondary.isNotEmpty)
              Text(
                secondary,
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }
}