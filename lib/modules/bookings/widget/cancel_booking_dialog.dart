import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
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
    final controller =
    Get.find<BookingsController>();

    return Dialog(
      insetPadding:
      const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(14),
              color: AppColors.dashboardRed,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cancel Booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.all(13),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(
                      10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softRed,
                      borderRadius:
                      BorderRadius.circular(
                        9,
                      ),
                    ),
                    child: Text(
                      'Are you sure you want to cancel this booking?\n\n'
                          'Cabin: ${booking.spaceName}\n'
                          'Start: ${booking.startDate} ${booking.startTime}',
                      style: const TextStyle(
                        color: AppColors
                            .lightTextPrimary,
                        fontSize: 7,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(
                      10,
                    ),
                    decoration: BoxDecoration(
                      color:
                      AppColors.softOrange,
                      borderRadius:
                      BorderRadius.circular(
                        9,
                      ),
                    ),
                    child: const Text(
                      'CANCELLATION POLICY\n\n'
                          'Cancellation charges may apply depending on the booking time.',
                      style: TextStyle(
                        color: AppColors
                            .dashboardOrange,
                        fontSize: 7,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child:
                        ElevatedButton(
                          onPressed: () {
                            controller
                                .cancelBooking(
                              booking.id,
                            );
                          },
                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            AppColors
                                .dashboardRed,
                            foregroundColor:
                            Colors.white,
                          ),
                          child: const Text(
                            'Cancel Booking',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: Get.back,
                          child: const Text(
                            'Close',
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
}