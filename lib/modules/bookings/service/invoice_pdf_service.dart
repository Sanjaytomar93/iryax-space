import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';

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
  // NotoSans supports ₹ (U+20B9). We pass the font everywhere.
  static String _rs(String amount) => 'Rs. $amount';
  static String _rsAmt(double v)   => 'Rs. ${v.toStringAsFixed(2)}';

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

  // ─── Share/Download directly (used from booking details dialog) ──
  static Future<void> downloadAndShare(BookingModel booking) async {
    try {
      final bytes = await _buildPdf(booking);
      await Printing.sharePdf(bytes: bytes, filename: _fileName(booking));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invoice generate karne mein dikkat aayi. Dobara try karein.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E1B2E),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

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

    final rawAmt =
        double.tryParse(b.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final subtotal = rawAmt > 0 ? rawAmt / 1.18 : 0.0;
    final gst      = rawAmt > 0 ? rawAmt - subtotal : 0.0;

    final endDate = b.endDate.isNotEmpty ? b.endDate : b.startDate;
    final endTime = b.endTime.isNotEmpty ? b.endTime : b.startTime;

    // Amount display: strip ₹ from model string & prefix with "Rs."
    final totalDisplay = b.amount.isNotEmpty
        ? _rs(b.amount.replaceAll(RegExp(r'[₹Rs.]'), '').trim())
        : 'Rs. 0';

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('IRYAX SPACE', style: tsB(size: 22)),
                  pw.SizedBox(height: 2),
                  pw.Text('Premium Workspaces', style: ts(size: 11, color: _textSec)),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: _whisper,
                      border: pw.Border.all(color: _border),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Text('CO-WORKING SPACE',
                        style: tsB(size: 9, color: _textMuted)),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('INVOICE', style: tsB(size: 20, color: _blue)),
                  pw.SizedBox(height: 4),
                  pw.Text('#$bookingRef', style: ts(size: 11, color: _textMuted)),
                  pw.SizedBox(height: 2),
                  pw.Text(_todayDate(), style: ts(size: 10, color: _textSec)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 18),
          pw.Divider(color: _border, thickness: 0.8),
          pw.SizedBox(height: 14),

          // ── Bill To & Cabin ───────────────────────────────
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Bill To
              pw.Expanded(child: _card(pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _label('BILL TO', tsB),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    b.customerName.isNotEmpty
                        ? b.customerName
                        : (StorageService.userName.isNotEmpty
                            ? StorageService.userName
                            : 'Customer'),
                    style: tsB(size: 13),
                  ),
                  if (b.customerMobile.isNotEmpty || StorageService.userMobile.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      b.customerMobile.isNotEmpty
                          ? b.customerMobile
                          : StorageService.userMobile,
                      style: ts(size: 10, color: _textSec),
                    ),
                  ],
                  if (b.customerEmail.isNotEmpty || StorageService.userEmail.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      b.customerEmail.isNotEmpty
                          ? b.customerEmail
                          : StorageService.userEmail,
                      style: ts(size: 10, color: _textSec),
                    ),
                  ],
                ],
              ))),
              pw.SizedBox(width: 14),
              // Cabin
              pw.Expanded(child: _card(pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _label('CABIN DETAILS', tsB),
                  pw.SizedBox(height: 6),
                  pw.Text(b.spaceName.isNotEmpty ? b.spaceName : 'Workspace',
                      style: tsB(size: 13)),
                  pw.SizedBox(height: 3),
                  pw.Text(b.location.isNotEmpty ? b.location : 'N/A',
                      style: ts(size: 10, color: _textSec)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Capacity: N/A seats | Type: ${b.spaceType.isNotEmpty ? b.spaceType : 'Normal'}',
                    style: ts(size: 10, color: _textSec),
                  ),
                ],
              ))),
            ],
          ),

          pw.SizedBox(height: 12),

          // ── Start & End ───────────────────────────────────
          _card(pw.Row(children: [
            pw.Expanded(child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _label('START', tsB),
                pw.SizedBox(height: 4),
                pw.Text(b.startDate.isNotEmpty ? b.startDate : '--',
                    style: tsB(size: 12)),
                if (b.startTime.isNotEmpty)
                  pw.Text(b.startTime, style: ts(size: 10, color: _textSec)),
              ],
            )),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10),
              child: pw.Text('-->',
                  style: ts(size: 13, color: _textMuted)),
            ),
            pw.Expanded(child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _label('END', tsB),
                pw.SizedBox(height: 4),
                pw.Text(endDate.isNotEmpty ? endDate : '--',
                    style: tsB(size: 12)),
                if (endTime.isNotEmpty)
                  pw.Text(endTime, style: ts(size: 10, color: _textSec)),
              ],
            )),
          ])),

          pw.SizedBox(height: 12),

          // ── Booking Info ──────────────────────────────────
          _card(pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _label('BOOKING INFORMATION', tsB),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _infoCol('Total Hours',  b.duration.isNotEmpty ? b.duration : '0h', ts, tsB),
                  _infoCol('Booking Type', 'Hourly', ts, tsB),
                  _infoCol('Seats',        '${b.seats}', ts, tsB),
                  _infoCol('Created',      b.createdAt.isNotEmpty ? b.createdAt : '--', ts, tsB),
                ],
              ),
            ],
          )),

          pw.SizedBox(height: 12),

          // ── Price Breakdown ───────────────────────────────
          _card(pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _label('PRICE BREAKDOWN', tsB),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Subtotal (${b.duration.isNotEmpty ? b.duration : '0h'} x Rs.0)',
                    style: ts(size: 11),
                  ),
                  pw.Text(_rsAmt(subtotal), style: ts(size: 11)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GST (18%)', style: ts(size: 11)),
                  pw.Text(_rsAmt(gst),  style: ts(size: 11)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: _border, thickness: 0.8),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Amount', style: tsB(size: 14)),
                  pw.Text(totalDisplay,
                      style: tsB(size: 16, color: _totalBlue)),
                ],
              ),
            ],
          )),

          pw.SizedBox(height: 12),

          // ── Status Strip ──────────────────────────────────
          _card(pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(children: [
                pw.Text('Status  ', style: ts(size: 10, color: _textSec)),
                _badge(_statusLabel(b.status), _statusBg(b.status),
                    _statusTxt(b.status), ts, tsB),
              ]),
              pw.Row(children: [
                pw.Text('Payment  ', style: ts(size: 10, color: _textSec)),
                _badge(
                  b.paymentMode == PaymentMode.cash ? 'Cash' : 'Online',
                  _blueBg, _blue, ts, tsB,
                ),
              ]),
              pw.Row(children: [
                pw.Text('Payment Status  ', style: ts(size: 10, color: _textSec)),
                _badge(
                  b.paymentStatus == PaymentStatus.paid ? 'Paid' : 'Pending',
                  b.paymentStatus == PaymentStatus.paid
                      ? const PdfColor.fromInt(0xFFDCFCE7)
                      : const PdfColor.fromInt(0xFFFEF3C7),
                  b.paymentStatus == PaymentStatus.paid
                      ? const PdfColor.fromInt(0xFF15803D)
                      : const PdfColor.fromInt(0xFFB45309),
                  ts, tsB,
                ),
              ]),
            ],
          )),

          pw.Spacer(),
          pw.Divider(color: _border, thickness: 0.5),
          pw.SizedBox(height: 6),

          // ── Footer ────────────────────────────────────────
          pw.Center(child: pw.Column(children: [
            pw.Text('IRYAX SPACE - Premium Workspaces',
                style: tsB(size: 10), textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 3),
            pw.Text(
              'This is a system generated invoice. Terms & Conditions apply.',
              style: ts(size: 9, color: _textSec),
              textAlign: pw.TextAlign.center,
            ),
          ])),
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
