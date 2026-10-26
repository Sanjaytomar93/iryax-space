import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';

class CancelBookingDialog extends StatelessWidget {
  const CancelBookingDialog({
    super.key,
    required this.booking,
  });

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingsController>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header Banner ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              color: const Color(0xFFE85B5B), // Vibrant red matching screenshot
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cancel Booking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          booking.spaceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Body ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Card 1: Confirmation & Details ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFEE2E2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Are you sure you want to cancel this booking?',
                          style: TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _detailRow('Cabin', booking.spaceName),
                        const SizedBox(height: 5),
                        _detailRow(
                          'Start',
                          '${booking.startDate} ${booking.startTime}'.trim(),
                        ),
                        const SizedBox(height: 5),
                        _detailRow(
                          'End',
                          '${booking.endDate} ${booking.endTime}'.trim(),
                        ),
                        const SizedBox(height: 5),
                        _detailRow(
                          'Total',
                          booking.amount.startsWith('₹')
                              ? booking.amount
                              : '₹${booking.amount}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Card 2: Cancellation Policy ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFEF3C7),
                        width: 1,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFB45309),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Cancellation Policy:',
                              style: TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '•  Free cancellation within 24 hours',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 12,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '•  50% refund after 24 hours',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 12,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '•  No refund for no-shows',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 12,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Buttons Row ──
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.cancelBooking(booking.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE85B5B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close_rounded, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Cancel Booking',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: Get.back,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
