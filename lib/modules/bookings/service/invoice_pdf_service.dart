import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/service/file_download_helper.dart';

class InvoicePdfService {
  // ─── Palette ─────────────────────────────────────────────
  static const _blue       = PdfColor.fromInt(0xFF1D4ED8);
  static const _blueBg     = PdfColor.fromInt(0xFFDBEAFE);
  static const _titleGray  = PdfColor.fromInt(0xFF111827);
  static const _textMuted  = PdfColor.fromInt(0xFF8A8A99);
  static const _textSec    = PdfColor.fromInt(0xFF6B7280);
  static const _border     = PdfColor.fromInt(0xFFE9ECF0);
  static const _whisper    = PdfColor.fromInt(0xFFF8F9FB);
  static const _totalBlue  = PdfColor.fromInt(0xFF2563EB);

  // ─── Rupee helper — avoids broken glyph ─────────────────
  static String _rsAmt(double v) => 'Rs. ${v.toStringAsFixed(2)}';

  // ─── Status helpers ──────────────────────────────────────
  static PdfColor _statusBg(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:  return _blueBg;
      case BookingStatus.active:     return const PdfColor.fromInt(0xFFDCFCE7);
      case BookingStatus.completed:  return const PdfColor.fromInt(0xFFF3E8FF);
      case BookingStatus.cancelled:  return const PdfColor.fromInt(0xFFFEE2E2);
      default:                       return const PdfColor.fromInt(0xFFFEF3C7);
    }
  }

  static PdfColor _statusTxt(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:  return _blue;
      case BookingStatus.active:     return const PdfColor.fromInt(0xFF15803D);
      case BookingStatus.completed:  return const PdfColor.fromInt(0xFF7E22CE);
      case BookingStatus.cancelled:  return const PdfColor.fromInt(0xFFB91C1C);
      default:                       return const PdfColor.fromInt(0xFFB45309);
    }
  }

  static String _statusLabel(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:  return 'CONFIRMED';
      case BookingStatus.active:     return 'ACTIVE';
      case BookingStatus.completed:  return 'COMPLETED';
      case BookingStatus.cancelled:  return 'CANCELLED';
      default:                       return 'PENDING';
    }
  }

  // ─── Preview — opens full PDF preview screen ────────────
  static Future<void> previewInvoice(BookingModel booking) async {
    await Get.to(
      () => Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.lightTextPrimary,
              size: 18,
            ),
            onPressed: Get.back,
          ),
          title: const Text(
            'Invoice Preview',
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: PdfPreview(
          build: (format) => _buildPdf(booking),
          allowPrinting: true,
          allowSharing: true,
          canChangePageFormat: false,
          canChangeOrientation: false,
          initialPageFormat: PdfPageFormat.a4,
          pdfFileName: _fileName(booking),
        ),
      ),
      transition: Transition.rightToLeft,
    );
  }

  static final Set<String> _downloadingIds = <String>{};

  // ─── Direct Download (MakeMyTrip style: save to device & notify) ──
  static Future<void> downloadInvoice(BookingModel booking) async {
    if (_downloadingIds.contains(booking.id)) return;
    _downloadingIds.add(booking.id);

    try {
      final fileName = _fileName(booking);
      final bytes = await _buildPdf(booking);

      final savedFile = await FileDownloadHelper.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/pdf',
      );

      final folderName =
          savedFile.path.contains('Download') ? 'Downloads' : 'Documents';

      FileDownloadHelper.showDownloadedNotification(
        fileName: fileName,
        folderName: folderName,
        filePath: savedFile.path,
        mimeType: 'application/pdf',
        onView: () => previewInvoice(booking),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invoice download fail ho gaya. Dobara try karein.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF26204A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      _downloadingIds.remove(booking.id);
    }
  }

  // Alias for backward compatibility with callers
  static Future<void> downloadAndShare(BookingModel booking) =>
      downloadInvoice(booking);

  static String _fileName(BookingModel b) {
    final ref = b.id.length > 8
        ? b.id.substring(b.id.length - 8).toUpperCase()
        : b.id.toUpperCase();
    return 'Invoice_IRYAX_$ref.pdf';
  }

  // ─── PDF Builder ─────────────────────────────────────────
  static Future<Uint8List> _buildPdf(BookingModel b) async {
    // Load NotoSans — it fully supports ₹ and all Latin glyphs
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold    = await PdfGoogleFonts.notoSansBold();

    // Convenience style factories
    pw.TextStyle ts({
      double size = 11,
      pw.FontWeight weight = pw.FontWeight.normal,
      PdfColor color = _titleGray,
    }) =>
        pw.TextStyle(font: regular, fontBold: bold, fontSize: size,
            fontWeight: weight, color: color);

    pw.TextStyle tsB({double size = 11, PdfColor color = _titleGray}) =>
        pw.TextStyle(font: bold, fontBold: bold, fontSize: size,
            fontWeight: pw.FontWeight.bold, color: color);

    final doc = pw.Document();

    final bookingRef = b.id.length > 8
        ? b.id.substring(b.id.length - 8).toUpperCase()
        : (b.id.isNotEmpty ? b.id.toUpperCase() : 'BOOKING');

    final hours = b.totalHours > 0 ? b.totalHours : 0.0;
    final days = b.totalDays > 0 ? b.totalDays : 1;
    final daily = b.dailyHours;
    final rate = b.hourlyRate;
    final subtotal = b.subtotalAmount;
    final seatCharge = b.extraCharge;
    final gst = b.gstAmount;
    final total = b.computedTotal > 0
        ? b.computedTotal
        : (double.tryParse(b.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0);

    final brand = b.spaceName.isNotEmpty ? b.spaceName.toLowerCase() : 'iryax space';
    final city = b.city.isNotEmpty
        ? b.city.toLowerCase()
        : (b.location.isNotEmpty
            ? b.location.split(',').first.trim().toLowerCase()
            : 'india');
    final txn = b.transactionId.isNotEmpty
        ? b.transactionId
        : (b.paymentMode == PaymentMode.cash
            ? 'CASH_$bookingRef'
            : 'N/A');
    final seatsLabel = b.selectedSeats.isNotEmpty
        ? b.selectedSeats.join(', ')
        : (b.seats > 0 ? 'Seat 1 (#1)' : 'N/A');

    final custName = b.customerName.isNotEmpty
        ? b.customerName
        : (StorageService.userName.isNotEmpty
            ? StorageService.userName
            : 'Customer');
    final custMobile = b.customerMobile.isNotEmpty
        ? b.customerMobile
        : StorageService.userMobile;
    final custEmail = b.customerEmail.isNotEmpty
        ? b.customerEmail
        : StorageService.userEmail;

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header — brand left, date right (image-2 style)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(brand, style: tsB(size: 22)),
                  pw.SizedBox(height: 2),
                  pw.Text(city, style: ts(size: 11, color: _textSec)),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(
                      color: _whisper,
                      border: pw.Border.all(color: _border),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Text(
                      b.shortTypeLabel.toUpperCase(),
                      style: tsB(size: 8.5, color: _textMuted),
                    ),
                  ),
                ],
              ),
              pw.Text(
                b.startDate.isNotEmpty ? b.startDate : _todayDate(),
                style: ts(size: 11, color: _textSec),
              ),
            ],
          ),

          pw.SizedBox(height: 12),
          pw.Divider(color: _border, thickness: 1),
          pw.SizedBox(height: 12),

          // Bill To + Cabin
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _card(pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _label('BILL TO', tsB),
                    pw.SizedBox(height: 6),
                    pw.Text(custName, style: tsB(size: 12)),
                    if (custMobile.isNotEmpty) ...[
                      pw.SizedBox(height: 3),
                      pw.Text(custMobile, style: ts(size: 10, color: _textSec)),
                    ],
                    if (custEmail.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(custEmail, style: ts(size: 10, color: _textSec)),
                    ],
                  ],
                )),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _card(pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _label('CABIN DETAILS', tsB),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      b.spaceName.isNotEmpty ? b.spaceName : 'Workspace',
                      style: tsB(size: 12),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      b.location.isNotEmpty ? b.location : city,
                      style: ts(size: 10, color: _textSec),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Capacity: ${b.capacity > 0 ? b.capacity : b.seats} seats | Type: ${b.cabinKind}',
                      style: ts(size: 10, color: _textSec),
                    ),
                  ],
                )),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // Start / End
          _card(pw.Row(children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _label('START', tsB),
                  pw.SizedBox(height: 4),
                  pw.Text(b.startDate, style: tsB(size: 11)),
                  pw.Text(b.startTime, style: ts(size: 10, color: _textSec)),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _label('END', tsB),
                  pw.SizedBox(height: 4),
                  pw.Text(b.endDate, style: tsB(size: 11)),
                  pw.Text(b.endTime, style: ts(size: 10, color: _textSec)),
                ],
              ),
            ),
          ])),

          pw.SizedBox(height: 10),

          // Metrics
          _card(pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _infoCol('TOTAL HOURS', hours > 0 ? '$hours' : b.duration, ts, tsB),
              _infoCol('TOTAL DAYS', '$days days', ts, tsB),
              _infoCol('DAILY HOURS', daily > 0 ? '$daily' : '—', ts, tsB),
              _infoCol('BOOKING TYPE', b.bookingBasis, ts, tsB),
            ],
          )),

          pw.SizedBox(height: 10),

          // Slots + Seats
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _card(pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _label('BOOKING SLOTS ($days DAYS)', tsB),
                    pw.SizedBox(height: 6),
                    pw.Text(b.startDate, style: tsB(size: 11)),
                    pw.Text(
                      '${b.startTime} - ${b.endTime}',
                      style: ts(size: 10, color: _textSec),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Daily Hours: ${daily > 0 ? daily : hours}',
                      style: ts(size: 10, color: _textSec),
                    ),
                  ],
                )),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _card(pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _label(
                      'SELECTED SEATS (${b.selectedSeats.isNotEmpty ? b.selectedSeats.length : b.seats})',
                      tsB,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(seatsLabel, style: tsB(size: 11)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Extra Charge: ${_rsAmt(seatCharge)}',
                      style: ts(size: 10, color: _textSec),
                    ),
                  ],
                )),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // Price table
          _card(pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('DESCRIPTION', style: tsB(size: 9, color: _textMuted)),
                  pw.Text('AMOUNT', style: tsB(size: 9, color: _textMuted)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Subtotal (${hours > 0 ? hours : b.duration} hours x Rs.${rate > 0 ? rate.toStringAsFixed(rate % 1 == 0 ? 0 : 2) : '0'})',
                      style: ts(size: 10),
                    ),
                  ),
                  pw.Text(_rsAmt(subtotal), style: ts(size: 10)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Seat Charges (${b.seats} seats x Rs.${seatCharge > 0 && b.seats > 0 ? (seatCharge / b.seats).toStringAsFixed(0) : '0'})',
                    style: ts(size: 10),
                  ),
                  pw.Text(_rsAmt(seatCharge), style: ts(size: 10)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GST (18%)', style: ts(size: 10)),
                  pw.Text(_rsAmt(gst), style: ts(size: 10)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: _border, thickness: 1),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Amount', style: tsB(size: 12)),
                  pw.Text(_rsAmt(total), style: tsB(size: 13, color: _totalBlue)),
                ],
              ),
            ],
          )),

          pw.SizedBox(height: 10),

          // Payment details
          _card(pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Transaction ID: $txn', style: ts(size: 10)),
              pw.SizedBox(height: 3),
              pw.Text(
                'Payment Mode: ${b.paymentMode == PaymentMode.cash ? 'Cash' : 'Online'}',
                style: ts(size: 10),
              ),
            ],
          )),

          pw.SizedBox(height: 10),

          // Status strip
          _card(pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(children: [
                pw.Text('Status  ', style: ts(size: 9, color: _textSec)),
                _badge(
                  _statusLabel(b.status),
                  _statusBg(b.status),
                  _statusTxt(b.status),
                  ts,
                  tsB,
                ),
              ]),
              pw.Row(children: [
                pw.Text('Payment  ', style: ts(size: 9, color: _textSec)),
                _badge(
                  b.paymentStatus == PaymentStatus.paid ? 'PAID' : 'PENDING',
                  b.paymentStatus == PaymentStatus.paid
                      ? const PdfColor.fromInt(0xFFDCFCE7)
                      : const PdfColor.fromInt(0xFFFEF3C7),
                  b.paymentStatus == PaymentStatus.paid
                      ? const PdfColor.fromInt(0xFF15803D)
                      : const PdfColor.fromInt(0xFFB45309),
                  ts,
                  tsB,
                ),
              ]),
              pw.Row(children: [
                pw.Text('Payment Method  ', style: ts(size: 9, color: _textSec)),
                pw.Text(
                  b.paymentMode == PaymentMode.cash ? 'Cash' : 'Online',
                  style: tsB(size: 10),
                ),
              ]),
            ],
          )),

          pw.Spacer(),
          pw.Divider(color: _border, thickness: 0.5),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
              '$brand — $city | Created: ${b.createdAt}',
              style: ts(size: 9, color: _textSec),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'POWERED BY IRYAX SPACE',
              style: tsB(size: 9, color: _textMuted),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    ));

    return doc.save();
  }

  // ── Shared Widgets ────────────────────────────────────────
  static pw.Widget _card(pw.Widget child) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _whisper,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          border: pw.Border.all(color: _border),
        ),
        child: child,
      );

  static pw.Widget _label(
    String text,
    pw.TextStyle Function({double size, PdfColor color}) tsB,
  ) =>
      pw.Text(text,
          style: tsB(size: 8.5, color: _textMuted));

  static pw.Widget _infoCol(
    String label,
    String value,
    pw.TextStyle Function({double size, pw.FontWeight weight, PdfColor color}) ts,
    pw.TextStyle Function({double size, PdfColor color}) tsB,
  ) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: ts(size: 8, color: _textMuted)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: tsB(size: 11)),
        ],
      );

  static pw.Widget _badge(
    String label,
    PdfColor bg,
    PdfColor textColor,
    pw.TextStyle Function({double size, pw.FontWeight weight, PdfColor color}) ts,
    pw.TextStyle Function({double size, PdfColor color}) tsB,
  ) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        ),
        child: pw.Text(label, style: tsB(size: 9, color: textColor)),
      );

  // ── Helpers ───────────────────────────────────────────────
  static String _todayDate() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/'
        '${n.month.toString().padLeft(2, '0')}/'
        '${n.year}';
  }
}
