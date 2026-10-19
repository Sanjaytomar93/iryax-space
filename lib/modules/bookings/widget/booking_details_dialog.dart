import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';

class BookingDetailsDialog extends StatelessWidget {
  const BookingDetailsDialog({
    super.key,
    required this.booking,
  });

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 30,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Booking Details',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _info(
                    'CUSTOMER DETAILS',
                    '${booking.customerName}\n'
                        '${booking.customerEmail}\n'
                        '${booking.customerMobile}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _info(
                    'CABIN DETAILS',
                    '${booking.spaceName}\n'
                        '${booking.location}\n'
                        '${booking.spaceType}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _info(
                    'START',
                    '${booking.startDate}\n${booking.startTime}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _info(
                    'END',
                    '${booking.endDate}\n${booking.endTime}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            _info(
              'BOOKING INFORMATION',
              'Hours: ${booking.duration}     '
                  'Days: ${booking.days}     '
                  'Seats: ${booking.seats}',
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Price Summary',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  _priceRow(
                    'Subtotal',
                    '₹900.00',
                  ),
                  _priceRow(
                    'Seat Charges',
                    '₹300.00',
                  ),
                  _priceRow(
                    'GST (18%)',
                    '₹216.00',
                  ),
                  const Divider(),
                  _priceRow(
                    'Total',
                    booking.amount,
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _info(
              'PAYMENT DETAILS',
              'Mode: ${booking.paymentMode.name}\n'
                  'Status: ${booking.paymentStatus.name}',
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.dashboardGreen,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.download_outlined,
                      size: 15,
                    ),
                    label: const Text(
                      'Download Invoice',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: Get.back,
                  child: const Text(
                    'Close',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(
      String title,
      String value,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.lightPrimary,
              fontSize: 6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 7,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
      String title,
      String value, {
        bool bold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 7,
                fontWeight: bold
                    ? FontWeight.w700
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: bold
                  ? AppColors.lightPrimary
                  : AppColors.lightTextPrimary,
              fontSize: 7,
              fontWeight: bold
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}