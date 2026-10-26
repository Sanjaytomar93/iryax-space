import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/model/site_visit_model.dart';
import 'package:iryax_spaces/modules/bookings/service/file_download_helper.dart';

/// Export format matches Numbers sheet: "Bookings October 2026"
class BookingsExportService {
  BookingsExportService._();

  static final RxBool isExportingBookings = false.obs;
  static final RxBool isExportingSiteVisits = false.obs;
  static bool _isAnyExporting = false;

  static const _headers = [
    'S.No',
    'Booking ID',
    'Type',
    'Basis',
    'Cabin',
    'Start Date',
    'Start Time',
    'End Date',
    'End Time',
    'Total Hours',
    'Total Days',
    'Daily Hours',
    'Slots',
    'Seats',
    'Seat Names',
    'Extra Charge',
    'Subtotal (₹)',
    'GST (₹)',
    'Total (₹)',
    'Status',
    'Payment',
    'Pmt Status',
    'Transaction ID',
    'UPI ID',
    'UPI App',
    'Check-in',
    'Check-out',
    'Visits',
    'Created At',
  ];

  static const _siteVisitsHeaders = [
    'S.No',
    'Visit ID',
    'Space Name',
    'Space Type',
    'Location',
    'Visit Date',
    'Visit Time',
    'Visitor Name',
    'Visitor Mobile',
    'Visitor Email',
    'Status',
    'Created At',
  ];

  static Future<void> downloadCsv({
    required BookingsController controller,
    required List<BookingModel> bookings,
  }) async {
    if (_isAnyExporting || isExportingBookings.value) return;

    if (bookings.isEmpty) {
      Get.snackbar(
        'No Data',
        'Download ke liye koi booking nahi mili.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF26204A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    _isAnyExporting = true;
    isExportingBookings.value = true;

    try {
      final fileName = _fileName('Bookings');
      final csv = _buildCsv(controller, bookings);
      // UTF-8 BOM so Excel/Numbers open ₹ columns correctly
      final bytes = utf8.encode('\uFEFF$csv');

      final savedFile = await FileDownloadHelper.saveFile(
        fileName: '$fileName.csv',
        bytes: bytes,
        mimeType: 'text/csv',
      );

      final folderName =
          savedFile.path.contains('Download') ? 'Downloads' : 'Documents';

      FileDownloadHelper.showDownloadedNotification(
        fileName: '$fileName.csv',
        folderName: folderName,
        filePath: savedFile.path,
        mimeType: 'text/csv',
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Bookings download fail ho gaya. Dobara try karein.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF26204A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isAnyExporting = false;
      isExportingBookings.value = false;
    }
  }

  static Future<void> downloadSiteVisitsCsv({
    required BookingsController controller,
    required List<SiteVisitModel> visits,
  }) async {
    if (_isAnyExporting || isExportingSiteVisits.value) return;

    if (visits.isEmpty) {
      Get.snackbar(
        'No Data',
        'Download ke liye koi site visit nahi mili.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF26204A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    _isAnyExporting = true;
    isExportingSiteVisits.value = true;

    try {
      final fileName = _fileName('Site Visits');
      final csv = _buildSiteVisitsCsv(controller, visits);
      // UTF-8 BOM so Excel/Numbers open columns correctly
      final bytes = utf8.encode('\uFEFF$csv');

      final savedFile = await FileDownloadHelper.saveFile(
        fileName: '$fileName.csv',
        bytes: bytes,
        mimeType: 'text/csv',
      );

      final folderName =
          savedFile.path.contains('Download') ? 'Downloads' : 'Documents';

      FileDownloadHelper.showDownloadedNotification(
        fileName: '$fileName.csv',
        folderName: folderName,
        filePath: savedFile.path,
        mimeType: 'text/csv',
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Site visits download fail ho gaya. Dobara try karein.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF26204A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isAnyExporting = false;
      isExportingSiteVisits.value = false;
    }
  }

  static String _fileName(String prefix) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '$prefix ${months[now.month - 1]} ${now.year}';
  }

  static String _buildCsv(
    BookingsController controller,
    List<BookingModel> bookings,
  ) {
    final rows = <List<String>>[_headers];

    for (var i = 0; i < bookings.length; i++) {
      final b = bookings[i];
      final total = _parseAmount(b.amount);
      final subtotal = total > 0 ? total / 1.18 : 0.0;
      final gst = total > 0 ? total - subtotal : 0.0;
      final hours = b.duration.replaceAll(RegExp(r'[^\d.]'), '');
      final days = b.days.replaceAll(RegExp(r'[^\d.]'), '');
      final dayCount = int.tryParse(days) ?? 1;
      final hoursVal = double.tryParse(hours) ?? 0;
      final dailyHours = dayCount > 0 && hoursVal > 0
          ? _num(hoursVal / dayCount)
          : hours;

      rows.add([
        '${i + 1}',
        _shortId(b.id),
        _typeLabel(b.spaceType),
        'hourly',
        b.spaceName,
        b.startDate,
        b.startTime,
        b.endDate,
        b.endTime,
        hours.isEmpty ? '0' : hours,
        days.isEmpty ? '1' : days,
        dailyHours,
        _slotLabel(b),
        '${b.seats}',
        'N/A',
        '0',
        _num(subtotal),
        _num(gst),
        _num(total),
        controller.bookingStatusText(b.status),
        controller.paymentModeText(b.paymentMode),
        controller.paymentStatusText(b.paymentStatus),
        b.paymentMode == PaymentMode.cash ? 'CASH' : 'N/A',
        'N/A',
        'N/A',
        'N/A',
        'N/A',
        '0',
        b.createdAt,
      ]);
    }

    return rows.map((row) => row.map(_escape).join(',')).join('\n');
  }

  static String _buildSiteVisitsCsv(
    BookingsController controller,
    List<SiteVisitModel> visits,
  ) {
    final rows = <List<String>>[_siteVisitsHeaders];

    for (var i = 0; i < visits.length; i++) {
      final v = visits[i];
      rows.add([
        '${i + 1}',
        _shortId(v.id),
        v.spaceName.isEmpty ? 'N/A' : v.spaceName,
        v.spaceType.isEmpty ? 'N/A' : v.spaceType,
        v.location.isEmpty ? 'N/A' : v.location,
        v.visitDate.isEmpty ? 'N/A' : v.visitDate,
        v.visitTime.isEmpty ? 'N/A' : v.visitTime,
        v.visitorName.isEmpty ? 'N/A' : v.visitorName,
        v.visitorMobile.isEmpty ? 'N/A' : v.visitorMobile,
        v.visitorEmail.isEmpty ? 'N/A' : v.visitorEmail,
        controller.siteVisitStatusText(v.status),
        v.createdAt.isEmpty ? 'N/A' : v.createdAt,
      ]);
    }

    return rows.map((row) => row.map(_escape).join(',')).join('\n');
  }

  static String _shortId(String id) {
    if (id.isEmpty) return 'N/A';
    if (id.length <= 8) return id.toUpperCase();
    return id.substring(id.length - 8).toUpperCase();
  }

  static String _typeLabel(String type) {
    final t = type.toLowerCase();
    if (t.contains('cafe')) return 'Cafe';
    if (t.contains('medical')) return 'Medical Chamber';
    if (t.contains('meeting')) return 'Meeting Room';
    if (t.contains('private')) return 'Private Office';
    return 'Co-Working Space';
  }

  static String _slotLabel(BookingModel b) {
    if (b.startDate == '--' || b.startTime.isEmpty) return 'N/A';
    if (b.endTime.isEmpty) return '${b.startDate} ${b.startTime}';
    return '${b.startDate} ${b.startTime}-${b.endTime}';
  }

  static double _parseAmount(String amount) {
    final cleaned = amount.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static String _num(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  static String _escape(String value) {
    final v = value.replaceAll('"', '""');
    if (v.contains(',') || v.contains('"') || v.contains('\n') || v.contains('\r')) {
      return '"$v"';
    }
    return v;
  }
}
