import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/model/site_visit_model.dart';
import 'package:iryax_spaces/modules/bookings/service/booking_service.dart';

import 'package:iryax_spaces/modules/bookings/widget/booking_details_dialog.dart';
import 'package:iryax_spaces/modules/bookings/widget/cancel_booking_dialog.dart';
import 'package:iryax_spaces/modules/bookings/widget/replace_space_dialog.dart';
import 'package:iryax_spaces/modules/bookings/widget/site_visit_details_dialog.dart';

class BookingsController extends GetxController {
  final searchController = TextEditingController();

  final BookingService _bookingService =
  BookingService();

  final selectedBookingTab = 0.obs;

  final selectedStatus = 'All Status'.obs;
  final selectedType = 'All Types'.obs;
  final selectedPaymentStatus =
      'Payment Status'.obs;

  final bookings = <BookingModel>[].obs;

  final siteVisits =
      <SiteVisitModel>[].obs;

  final isLoadingBookings = false.obs;
  final isLoadingVisits = false.obs;

  final bookingError = RxnString();
  final visitError = RxnString();

  final selectedBookingDate = Rxn<DateTime>();
  final searchQuery = ''.obs;

  final siteVisitSearchQuery = ''.obs;

  final selectedVisitStatus =
      'All Status'.obs;

  final selectedVisitType =
      'All Types'.obs;

  final selectedBookingStat =
      'All'.obs;

  final selectedVisitDate =
  Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();

    loadBookings();
    loadSiteVisits();
  }


  List<BookingModel> get filteredBookings {
    final query = searchQuery.value.trim().toLowerCase();

    return bookings.where((booking) {
      final matchesSearch =
          query.isEmpty ||
              booking.spaceName.toLowerCase().contains(query) ||
              booking.location.toLowerCase().contains(query) ||
              booking.customerName.toLowerCase().contains(query);

      final matchesStatus =
      selectedBookingStat.value ==
          'Active & Confirmed'
          ? booking.status ==
          BookingStatus.active ||
          booking.status ==
              BookingStatus.confirmed
          : selectedStatus.value ==
          'All Status' ||
          bookingStatusText(
            booking.status,
          ) ==
              selectedStatus.value;

      // final matchesStatus =
      //     selectedStatus.value == 'All Status' ||
      //         bookingStatusText(booking.status) ==
      //             selectedStatus.value;

      final matchesType =
          selectedType.value == 'All Types' ||
              booking.spaceType
                  .trim()
                  .toLowerCase() ==
                  selectedType.value
                      .trim()
                      .toLowerCase();

      final matchesPayment =
          selectedPaymentStatus.value ==
              'Payment Status' ||
              paymentStatusText(
                booking.paymentStatus,
              ) ==
                  selectedPaymentStatus.value;

      final matchesDate =
          selectedBookingDate.value == null ||
              _isSameBookingDate(
                booking.startDate,
                selectedBookingDate.value!,
              );

      return matchesSearch &&
          matchesStatus &&
          matchesType &&
          matchesPayment &&
          matchesDate;
    }).toList();
  }


  List<SiteVisitModel>
  get filteredSiteVisits {
    final query =
    siteVisitSearchQuery.value
        .trim()
        .toLowerCase();

    return siteVisits.where(
          (visit) {
        final matchesSearch =
            query.isEmpty ||
                visit.spaceName
                    .toLowerCase()
                    .contains(query) ||
                visit.location
                    .toLowerCase()
                    .contains(query) ||
                visit.visitorName
                    .toLowerCase()
                    .contains(query) ||
                visit.visitorMobile
                    .toLowerCase()
                    .contains(query);

        final matchesStatus =
            selectedVisitStatus.value ==
                'All Status' ||
                siteVisitStatusText(
                  visit.status,
                ) ==
                    selectedVisitStatus.value;

        final matchesType =
            selectedVisitType.value ==
                'All Types' ||
                visit.spaceType
                    .trim()
                    .toLowerCase() ==
                    selectedVisitType.value
                        .trim()
                        .toLowerCase();

        final matchesDate =
            selectedVisitDate.value ==
                null ||
                _isSameBookingDate(
                  visit.visitDate,
                  selectedVisitDate.value!,
                );

        return matchesSearch &&
            matchesStatus &&
            matchesType &&
            matchesDate;
      },
    ).toList();
  }

  void changeBookingStat(
      String value,
      ) {
    selectedBookingStat.value =
        value;

    if (value ==
        'Active & Confirmed') {
      selectedStatus.value =
      'All Status';
      return;
    }

    selectedStatus.value =
    value == 'All'
        ? 'All Status'
        : value;
  }



  void updateSiteVisitSearch(
      String value,
      ) {
    siteVisitSearchQuery.value =
        value;
  }

  void changeVisitStatus(
      String value,
      ) {
    selectedVisitStatus.value =
        value;
  }

  void changeVisitType(
      String value,
      ) {
    selectedVisitType.value =
        value;
  }

  void changeVisitDate(
      DateTime? value,
      ) {
    selectedVisitDate.value =
        value;
  }

  void clearSiteVisitFilters() {
    siteVisitSearchQuery.value = '';

    selectedVisitStatus.value =
    'All Status';

    selectedVisitType.value =
    'All Types';

    selectedVisitDate.value =
    null;
  }


  bool _isSameBookingDate(
      String bookingDate,
      DateTime selectedDate,
      ) {
    try {
      final parts =
      bookingDate.split('/');

      if (parts.length != 3) {
        return false;
      }

      final first =
          int.tryParse(parts[0]) ?? 0;
      final second =
          int.tryParse(parts[1]) ?? 0;
      final year =
          int.tryParse(parts[2]) ?? 0;

      // Your model currently commonly uses dd/MM/yyyy.
      final parsed = DateTime(
        year,
        second,
        first,
      );

      return parsed.year ==
          selectedDate.year &&
          parsed.month ==
              selectedDate.month &&
          parsed.day ==
              selectedDate.day;
    } catch (_) {
      return false;
    }
  }


  void updateSearch(
      String value,
      ) {
    searchQuery.value = value;
  }

  void changeStatus(
      String value,
      ) {
    selectedStatus.value = value;

    selectedBookingStat.value =
    value == 'All Status'
        ? 'All'
        : value;
  }

  void changeType(
      String value,
      ) {
    selectedType.value = value;
  }

  void changePaymentStatus(
      String value,
      ) {
    selectedPaymentStatus.value = value;
  }

  void changeBookingDate(
      DateTime? value,
      ) {
    selectedBookingDate.value = value;
  }

  void clearDashboardFilters() {
    searchController.clear();

    searchQuery.value = '';

    selectedStatus.value =
    'All Status';

    selectedBookingStat.value =
    'All';

    selectedType.value =
    'All Types';

    selectedPaymentStatus.value =
    'Payment Status';

    selectedBookingDate.value =
    null;
  }


  Future<void> loadBookings() async {
    try {
      isLoadingBookings.value = true;
      bookingError.value = null;

      final result =
      await _bookingService
          .getUserBookings();

      bookings.assignAll(
        result,
      );
    } catch (e) {
      bookingError.value = e
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );
    } finally {
      isLoadingBookings.value =
      false;
    }
  }

  Future<void> loadSiteVisits() async {
    try {
      isLoadingVisits.value = true;
      visitError.value = null;

      debugPrint(
        'SITE VISITS: loading...',
      );

      final result =
      await _bookingService
          .getUserVisits();

      debugPrint(
        'SITE VISITS API COUNT: ${result.length}',
      );

      for (final visit in result) {
        debugPrint(
          'SITE VISIT => '
              'id=${visit.id}, '
              'space=${visit.spaceName}, '
              'date=${visit.visitDate}, '
              'time=${visit.visitTime}, '
              'status=${visit.status}',
        );
      }

      siteVisits.assignAll(
        result,
      );

      debugPrint(
        'SITE VISITS CONTROLLER COUNT: ${siteVisits.length}',
      );
    } catch (e) {
      visitError.value = e
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint(
        'SITE VISITS ERROR: ${visitError.value}',
      );
    } finally {
      isLoadingVisits.value =
      false;
    }
  }


  Future<void> refreshCurrentTab() async {
    if (selectedBookingTab.value == 0) {
      await loadBookings();
    } else {
      await loadSiteVisits();
    }
  }

  void changeBookingTab(
      int index,
      ) {
    selectedBookingTab.value =
        index;

    searchController.clear();

    if (index == 0) {
      searchQuery.value = '';
    } else {
      siteVisitSearchQuery.value =
      '';
    }

    if (index == 0 &&
        bookings.isEmpty &&
        !isLoadingBookings.value) {
      loadBookings();
    }

    if (index == 1 &&
        siteVisits.isEmpty &&
        !isLoadingVisits.value) {
      loadSiteVisits();
    }
  }


  int bookingCount(
      BookingStatus status,
      ) {
    return bookings
        .where(
          (item) =>
      item.status == status,
    )
        .length;
  }

  int siteVisitCount(
      SiteVisitStatus status,
      ) {
    return siteVisits
        .where(
          (item) =>
      item.status == status,
    )
        .length;
  }

  String bookingStatusText(
      BookingStatus status,
      ) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';

      case BookingStatus.confirmed:
        return 'Confirmed';

      case BookingStatus.active:
        return 'Active';

      case BookingStatus.completed:
        return 'Completed';

      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String paymentStatusText(
      PaymentStatus status,
      ) {
    return status ==
        PaymentStatus.paid
        ? 'Paid'
        : 'Pending';
  }

  String paymentModeText(
      PaymentMode mode,
      ) {
    return mode ==
        PaymentMode.cash
        ? 'Cash'
        : 'Online';
  }

  String siteVisitStatusText(
      SiteVisitStatus status,
      ) {
    switch (status) {
      case SiteVisitStatus.pending:
        return 'Pending';

      case SiteVisitStatus.confirmed:
        return 'Confirmed';

      case SiteVisitStatus.completed:
        return 'Completed';

      case SiteVisitStatus.cancelled:
        return 'Cancelled';
    }
  }

  void openBookingDetails(
      BookingModel booking,
      ) {
    Get.dialog(
      BookingDetailsDialog(
        booking: booking,
      ),
    );
  }

  void openReplaceSpace(
      BookingModel booking,
      ) {
    Get.dialog(
      ReplaceSpaceDialog(
        booking: booking,
      ),
    );
  }

  void openCancelBooking(
      BookingModel booking,
      ) {
    Get.dialog(
      CancelBookingDialog(
        booking: booking,
      ),
    );
  }

  void openSiteVisitDetails(
      SiteVisitModel visit,
      ) {
    Get.dialog(
      SiteVisitDetailsDialog(
        visit: visit,
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }


  Future<void> cancelBooking(
      String id,
      ) async {
    try {
      final response =
      await _bookingService
          .cancelBooking(id);

      final message =
          response['message']?.toString() ??
              'Booking cancelled successfully.';

      Get.back();

      await loadBookings();

      Get.snackbar(
        'Booking Cancelled',
        message,
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Cancel Failed',
        e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition:
        SnackPosition.BOTTOM,
      );
    }
  }

  
}