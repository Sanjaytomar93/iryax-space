import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/service/invoice_pdf_service.dart';


// ─────────────────────────────────────────────────────────
// Color Palette matching the exact reference card design
// ─────────────────────────────────────────────────────────
class _DC {
  static const white = Color(0xFFFFFFFF);
  static const whisper = Color(0xFFF8F9FB);
  static const border = Color(0xFFE9ECF0);
  static const steelGray = Color(0xFF1E1B2E);
  static const titleGray = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF8A8A99);

  // Total Blue in Price Breakdown
  static const totalBlue = Color(0xFF2563EB);

  // Payment Mode (Cash / Online) -> Blue badge
  static const paymentModeBg = Color(0xFFDBEAFE);
  static const paymentModeText = Color(0xFF1D4ED8);

  // Status Badges
  static const confirmedBg = Color(0xFFDBEAFE);
  static const confirmedText = Color(0xFF1D4ED8);

  static const pendingBg = Color(0xFFFEF3C7);
  static const pendingText = Color(0xFFB45309);

  static const activeBg = Color(0xFFDCFCE7);
  static const activeText = Color(0xFF15803D);

  static const completedBg = Color(0xFFF3E8FF);
  static const completedText = Color(0xFF7E22CE);

  static const cancelledBg = Color(0xFFFEE2E2);
  static const cancelledText = Color(0xFFB91C1C);

  // Buttons
  static const invoiceGreen = Color(0xFF0F804E);
  static const closeBtnBg = Color(0xFFF3F4F6);
  static const closeBtnText = Color(0xFF374151);
}

class BookingDetailsDialog extends StatelessWidget {
  const BookingDetailsDialog({
    super.key,
    required this.booking,
  });

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final bookingRef = booking.id.length > 8
        ? booking.id.substring(booking.id.length - 8).toUpperCase()
        : (booking.id.isNotEmpty ? booking.id.toUpperCase() : 'REF-BOOKING');

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            decoration: BoxDecoration(
              color: _DC.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── Header ───
                _buildHeader(bookingRef),

                // ─── Body Content ───
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Customer Details & Cabin Details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCustomerCard()),
                            const SizedBox(width: 10),
                            Expanded(child: _buildCabinCard()),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Row 2: Start & End Schedule (Connected style with arrow as previously built)
                        _buildStartEndSchedule(),

                        const SizedBox(height: 10),

                        // Row 3: Booking Information Card
                        _buildBookingInfoCard(),

                        const SizedBox(height: 10),

                        // Row 4: Price Breakdown Card
                        _buildPriceBreakdownCard(),

                        const SizedBox(height: 10),

                        // Row 5: Status / Payment Strip
                        _buildStatusStrip(),

                        const SizedBox(height: 14),

                        // Row 6: Action Buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════
  Widget _buildHeader(String bookingRef) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: _DC.white,
        border: Border(bottom: BorderSide(color: _DC.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFF4F46E5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: _DC.titleGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    if (booking.id.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: booking.id));
                      Get.snackbar(
                        'Copied',
                        'Booking ID copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                        backgroundColor: _DC.steelGray,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(12),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        '#$bookingRef',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: _DC.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.copy_rounded,
                        size: 11,
                        color: _DC.textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: Get.back,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              minimumSize: const Size(28, 28),
            ),
            icon: const Icon(
              Icons.close_rounded,
              color: _DC.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // CARD 1: CUSTOMER DETAILS
  // ══════════════════════════════════════════════════════
  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DC.whisper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CUSTOMER DETAILS',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: _DC.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            booking.customerName.isNotEmpty ? booking.customerName : 'Customer',
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: _DC.titleGray,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (booking.customerEmail.isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 12, color: _DC.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.customerEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: _DC.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (booking.customerMobile.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 12, color: _DC.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.customerMobile,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: _DC.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // CARD 2: CABIN DETAILS
  // ══════════════════════════════════════════════════════
  Widget _buildCabinCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DC.whisper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CABIN DETAILS',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: _DC.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            booking.spaceName.isNotEmpty ? booking.spaceName : 'Cabin Workspace',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: _DC.titleGray,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (booking.location.isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 12, color: _DC.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: _DC.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            booking.spaceType.isNotEmpty
                ? 'Type: ${booking.spaceType}'
                : 'Type: Workspace',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: _DC.textSecondary,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // START & END SCHEDULE (PREVIOUS CONNECTED CARD STYLE)
  // ══════════════════════════════════════════════════════
  Widget _buildStartEndSchedule() {
    final endDate = booking.endDate.isNotEmpty ? booking.endDate : booking.startDate;
    final endTime = booking.endTime.isNotEmpty ? booking.endTime : booking.startTime;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DC.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DC.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _dateTimeBlock(
              label: 'START',
              date: booking.startDate,
              time: booking.startTime,
              color: const Color(0xFF4338CA),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: _DC.textMuted.withValues(alpha: 0.6),
            ),
          ),
          Expanded(
            child: _dateTimeBlock(
              label: 'END',
              date: endDate,
              time: endTime,
              color: _DC.steelGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeBlock({
    required String label,
    required String date,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _DC.whisper,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: _DC.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date.isNotEmpty ? date : '--',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (time.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: _DC.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // BOOKING INFORMATION CARD
  // ══════════════════════════════════════════════════════
  Widget _buildBookingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DC.whisper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BOOKING INFORMATION',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: _DC.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoCol('Total Hours', booking.duration.isNotEmpty ? booking.duration : '0h'),
              _infoCol('Booking Type', 'Hourly'),
              _infoCol('Seats', '${booking.seats}'),
              _infoCol(
                'Created',
                booking.createdAt.isNotEmpty ? booking.createdAt : '--',
                isDate: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCol(String label, String value, {bool isDate = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: _DC.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: _DC.titleGray,
              fontSize: isDate ? 10.5 : 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PRICE BREAKDOWN CARD
  // ══════════════════════════════════════════════════════
  Widget _buildPriceBreakdownCard() {
    // Parse numeric amount to calculate reasonable breakdown if needed
    final rawNumber = double.tryParse(booking.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final subtotal = rawNumber > 0 ? (rawNumber / 1.18).round() : 0;
    final gst = rawNumber > 0 ? (rawNumber - subtotal).round() : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DC.whisper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRICE BREAKDOWN',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: _DC.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${booking.duration.isNotEmpty ? booking.duration : '0h'} × ₹0)',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.titleGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '₹$subtotal',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.titleGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // GST (18%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GST (18%)',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.titleGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '₹$gst',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.titleGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: _DC.border),
          const SizedBox(height: 8),

          // Total Amount (Highlighted Blue)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.titleGray,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                booking.amount.isNotEmpty ? booking.amount : '₹0',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.totalBlue,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // STATUS & PAYMENT MODE STRIP
  // ══════════════════════════════════════════════════════
  Widget _buildStatusStrip() {
    final modeText = booking.paymentMode.name.capitalizeFirst ?? 'Online';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _DC.whisper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _DC.border),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        spacing: 6,
        runSpacing: 6,
        children: [
          // Status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Status: ',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg(booking.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(booking.status),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: _statusText(booking.status),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Payment Mode (Always Blue Badge as requested!)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Payment: ',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _DC.paymentModeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  modeText,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: _DC.paymentModeText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Payment Status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Payment Status: ',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: _DC.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: booking.paymentStatus == PaymentStatus.paid
                      ? _DC.activeBg
                      : _DC.pendingBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.paymentStatus == PaymentStatus.paid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: booking.paymentStatus == PaymentStatus.paid
                        ? _DC.activeText
                        : _DC.pendingText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // ACTION BUTTONS (Download Invoice + Close)
  // ══════════════════════════════════════════════════════
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Download Invoice (Green)
        ElevatedButton.icon(
          onPressed: () => InvoicePdfService.downloadAndShare(booking),
          icon: const Icon(
            Icons.download_rounded,
            size: 15,
            color: Colors.white,
          ),
          label: const Text(
            'Download Invoice',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _DC.invoiceGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Close Button
        TextButton(
          onPressed: Get.back,
          style: TextButton.styleFrom(
            backgroundColor: _DC.closeBtnBg,
            foregroundColor: _DC.closeBtnText,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Close',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Status Helpers ──
  Color _statusBg(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return _DC.pendingBg;
      case BookingStatus.confirmed:
        return _DC.confirmedBg;
      case BookingStatus.active:
        return _DC.activeBg;
      case BookingStatus.completed:
        return _DC.completedBg;
      case BookingStatus.cancelled:
        return _DC.cancelledBg;
    }
  }

  Color _statusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return _DC.pendingText;
      case BookingStatus.confirmed:
        return _DC.confirmedText;
      case BookingStatus.active:
        return _DC.activeText;
      case BookingStatus.completed:
        return _DC.completedText;
      case BookingStatus.cancelled:
        return _DC.cancelledText;
    }
  }

  String _statusLabel(BookingStatus status) {
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
}