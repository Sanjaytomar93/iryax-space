import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';

class ReplaceSpaceDialog extends StatefulWidget {
  const ReplaceSpaceDialog({
    super.key,
    required this.booking,
  });

  final BookingModel booking;

  @override
  State<ReplaceSpaceDialog> createState() =>
      _ReplaceSpaceDialogState();
}

class _ReplaceSpaceDialogState
    extends State<ReplaceSpaceDialog> {
  String? selectedCabin;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
      const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(14),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(14),
                decoration:
                const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors
                          .gradientBlueStart,
                      AppColors
                          .gradientPurpleEnd,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Replace Space',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
                const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.all(
                        10,
                      ),
                      decoration: BoxDecoration(
                        color:
                        AppColors.softBlue,
                        borderRadius:
                        BorderRadius
                            .circular(9),
                      ),
                      child: Text(
                        'CURRENT BOOKING\n\n'
                            '${widget.booking.spaceName}\n'
                            '${widget.booking.startDate} '
                            '${widget.booking.startTime}',
                        style: const TextStyle(
                          color: AppColors
                              .lightTextPrimary,
                          fontSize: 7,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'SELECT NEW CABIN',
                      style: TextStyle(
                        color: AppColors
                            .lightTextSecondary,
                        fontSize: 6,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    DropdownButtonFormField<
                        String>(
                      value: selectedCabin,
                      decoration:
                      InputDecoration(
                        filled: true,
                        fillColor: AppColors
                            .lightBackground,
                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(8),
                          borderSide:
                          const BorderSide(
                            color: AppColors
                                .lightBorder,
                          ),
                        ),
                      ),
                      hint: const Text(
                        'Select Cabin',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value:
                          'Cabin-1',
                          child: Text(
                            'Cabin-1',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                          'Cabin-2',
                          child: Text(
                            'Cabin-2',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                          'Cabin-3',
                          child: Text(
                            'Cabin-3',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCabin =
                              value;
                        });
                      },
                    ),

                    if (selectedCabin !=
                        null) ...[
                      const SizedBox(
                        height: 12,
                      ),

                      const Text(
                        'PRICE COMPARISON',
                        style: TextStyle(
                          color: AppColors
                              .lightTextSecondary,
                          fontSize: 6,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: _priceBox(
                              'Old',
                              widget.booking
                                  .amount,
                              AppColors
                                  .softBlue,
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Expanded(
                            child: _priceBox(
                              'New',
                              '₹840',
                              AppColors
                                  .softGreen,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Container(
                        width:
                        double.infinity,
                        padding:
                        const EdgeInsets
                            .all(9),
                        decoration:
                        BoxDecoration(
                          color: AppColors
                              .softOrange,
                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),
                        child:
                        const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Extra To Pay',
                                style:
                                TextStyle(
                                  color: AppColors
                                      .dashboardOrange,
                                  fontSize:
                                  7,
                                ),
                              ),
                            ),
                            Text(
                              '+₹486',
                              style:
                              TextStyle(
                                color: AppColors
                                    .dashboardOrange,
                                fontSize: 8,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    Align(
                      alignment:
                      Alignment.center,
                      child:
                      ElevatedButton(
                        onPressed:
                        selectedCabin ==
                            null
                            ? null
                            : () {
                          Get.back();

                          Get.snackbar(
                            'Booking Replaced',
                            'Booking replaced successfully.',
                            snackPosition:
                            SnackPosition
                                .BOTTOM,
                          );
                        },
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          AppColors
                              .lightPrimary,
                          foregroundColor:
                          Colors.white,
                        ),
                        child: const Text(
                          'Replace Booking',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceBox(
      String title,
      String amount,
      Color background,
      ) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors
                  .lightTextSecondary,
              fontSize: 6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            amount,
            style: const TextStyle(
              color:
              AppColors.lightPrimary,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}